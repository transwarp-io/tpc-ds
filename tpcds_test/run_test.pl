#!/usr/bin/perl
#
# the script aim to run all the available tpcds tests automatically, and generate the report 
#
use Term::ANSIColor;
use Getopt::Std;
#          (config query  tag    skip   command  help   CRC    KeepPerf Debug)
use vars qw($opt_i $opt_f $opt_t $opt_s $opt_r $opt_h $opt_c $opt_k $opt_d);
getopts('i:f:t:s:r:hdck');

#Process input parameters
&processOption;

#import PATH env
$path = $ENV{'PATH'};

#Create the log and perf files
$timeStamp = &genTimeStamp();
$database = &getDatabase();

$hostname = `hostname`;
chomp $hostname;
$uniName = $hostname."_".$database."_".$timeStamp.$opt_t;
system("mkdir -p ./logs/$uniName");
system("mkdir -p ./perf/$uniName");
open PERFLOG, '>', "./perf/$uniName/perf.log" or die;
open PERFCSV, '>', "./perf/$uniName/perf.csv" or die;

#print log/perf file directory
print "logs dir : ./logs/$uniName/\n";
print "perf file: ./perf/$uniName/perf.log\n";
print "--------------------------------------------------------\n";
&printAll("Database: $database\n");
&printAll("HostName: $hostname\n");


print "Start run time: $timeStamp\n";
&printAll("NO", -1, "Test Name  ", -1, "Time", -1, "Latest N Run Result");
if($opt_c) {&printAll(-1, "CRC")}
&printAll("\n");

@allTime = (0,0,0,0);

my $sql_shell = $opt_r;

if($opt_f){
    $exit_code = 0;
    #Process standalone mode
    $num = "-";
    $second = 0;
    $i = $opt_f;
    $sql = "query".$i.".sql";
    my $cmd = "$sql_shell -i $opt_i -f ./sql/$sql > ./logs/$uniName/$sql.log 2>&1";
    &printAll($num, -1, $sql);
    my $ret = system($cmd);
    #accumulate the time of all the steps from the log file
    open LOG, '<', "./logs/$uniName/$sql.log" or die;
    while($line = <LOG>) {
        if($line =~ /Time taken:/) {
            if($line =~ /Time taken:\s(\d+)/){ 
                $second += $1;
            }
        }
    }
    close LOG;

    # say if elapsed time < 2s, we default the test is failed
    if($second >= 1 && $ret == 0){ 
        my @times = &findLatest(3, $i);
        &printAll(-1, $second);
        printf         "\t[%4d, %4d, %4d]", $times[0], $times[1], $times[2];
        printf PERFLOG "\t[%4d, %4d, %4d]", $times[0], $times[1], $times[2];
        printf PERFCSV "\t[%4d, %4d, %4d]", $times[0], $times[1], $times[2];
        $allTime[0] += $second;
        $allTime[1] += $times[0];
        $allTime[2] += $times[1];
        $allTime[3] += $times[2];
        
        if($opt_c) {
            
            &refCheck("./logs/$uniName/", $i,$opt_f);
        }
    }
    else{
        print PERFLOG "\t\tFail, Error log: ./logs/$uniName/$sql.log\n\t\t\t\tReproduce cmd: $cmd";
        print         "\t\tFail, Error log: ./logs/$uniName/$sql.log\n\t\t\t\tReproduce cmd: $cmd";
        exit(1);
    }
#    if($second >= 1 && $ret == 0){ &printAll("\n");}
    &printAll("\n");
}else{
    $exit_code = 0;
    #Process all sql files
    $num=1;
    for($i = 1; $i <= 99; $i++) {
        $sql    = "query".$i.".sql";
        $second = 0;
        next if(!(-e "sql/fullset/$sql"));
        #if the test has been  added to the skip list,so skip
        if($opt_s){
            if(scalar(`grep "\\<$i\\>" $opt_s`)){
                print "skip test $i\n";
                next;
            }
        }
        $cmd = "$sql_shell -i $opt_i -f ./sql/$sql > ./logs/$uniName/$sql.log 2>&1";
        &printAll($num, -1, $sql);
        $ret = system($cmd);

        #accumulate the time of all the steps from the log file
        open LOG, '<', "./logs/$uniName/$sql.log" or die;
        while($line = <LOG>) {
            if($line =~ /Time taken:/) {
                if($line =~ /Time taken:\s(\d+)/){ 
                    $second += $1;
              }
          }
        }
        close LOG;

        # say if elapsed time < 2s, we default the test is failed
        if($second >= 1 && $ret == 0){ 
            my @times = &findLatest(3, $i);
            &printAll(-1, $second);
            printf         "\t[%4d, %4d, %4d]", $times[0], $times[1], $times[2];
            printf PERFLOG "\t[%4d, %4d, %4d]", $times[0], $times[1], $times[2];
            printf PERFCSV "\t[%4d, %4d, %4d]", $times[0], $times[1], $times[2];
            $allTime[0] += $second;
            $allTime[1] += $times[0];
            $allTime[2] += $times[1];
            $allTime[3] += $times[2];
        
            if($opt_c) {
                &refCheck("./logs/$uniName/", $i,$opt_f);
            }
        }
        else{
            print PERFLOG "\t\tFail, Error log: ./logs/$uniName/$sql.log\n\t\t\t\tReproduce cmd: $cmd";
            print         "\t\tFail, Error log: ./logs/$uniName/$sql.log\n\t\t\t\tReproduce cmd: $cmd";
            $exit_code = 1;
        }
    #    if($second >= 1 && $ret == 0){ &printAll("\n");}
        &printAll("\n");
        $num++;  
    }
    &printAll ("--------------------------------------------------------\n");
    printf         "All: %5d\t[%5d, %5d, %5d]", $allTime[0], $allTime[1], $allTime[2], $allTime[3];
    printf PERFLOG "All: %5d\t[%5d, %5d, %5d]", $allTime[0], $allTime[1], $allTime[2], $allTime[3];
    printf PERFCSV "All: %5d\t[%5d, %5d, %5d]", $allTime[0], $allTime[1], $allTime[2], $allTime[3];
    &printAll("\n");
}

close PERFLOG;
close PERFCSV;

if($opt_k) {
    my $cmd =   "svn add ./perf/$uniName;";
    $cmd = $cmd."svn commit -m \"WARP-1214 Add perf data to server for later reference\" ./perf/$uniName";
    system($cmd);
}

exit($exit_code);

#----------------------------------------------------------------------------------------------------------------------------------#
#            Functions                                                                                                             #
#----------------------------------------------------------------------------------------------------------------------------------#

#return time stamp as string
sub genTimeStamp{
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time());
    my $format_time = sprintf("%04d-%02d-%02d-%02d-%02d-%02d",$year+1900,$mon+1,$mday,$hour,$min,$sec);
    return $format_time;
}

#process input parameters
sub processOption{
    if($opt_h) {
        print "-h  help info\n";
        print "-i  specify a file as the config, default to ./config, the file can include:\n";
        print "    use tpcds_orc_100;\n";
        print "-f  assign the exact sql file instead of all the tpcds tests, and run as the standalone mode\n";
        print "-t  add tag to the run\n";
        print "-c  ref check\n";
        print "-k  keep the perf info to svn\n";
        print "-s  skip the test set\n";
        print "Example: \n";
        print "    genPerf.pl -i config -c\n";
        exit(0);
    }
    if(!$opt_i){
        if(-e "./config") { $opt_i = "./config"; }
        else { print "Default config file ./config doesn't exists, please add one.\n"; exit(0); }
    }
    elsif(!(-e $opt_i)) {
        print "Config file $opt_i doesn't exists, please add the correct one.\n";
        exit(0);
    }
    # display the config to user for attention
    print "Your config file is:\n";
    print "--------------------------------------------------------\n";
    system("cat $opt_i");
    print "--------------------------------------------------------\n";
}

#ref check for function issue
sub refCheck{
    my $log = $_[0];
    my $i   = $_[1];
    my $opt_f = $_[2];
    if(!(-e "./reference/query$i.sql.log")) { &printAll(-1, "NO REF"); $exit_code = 1;}
    else{
        system("perl ./script/parse.pl $log/query$i.sql.log > tmp1");
        system("perl ./script/parse.pl ./reference/query$i.sql.log > tmp2");
        my $ret = 0; # system("diff tmp1 tmp2 > 1");
        #ignore the order, some times the fields order by is the same, so the order maybe not stable
        open TMP1, '<', "tmp1";
        foreach my $line(<TMP1>) {
            chomp $line;
            $line =~ s/\'/\./g;
            my $command = "grep '$line' tmp2";
            if ($line =~ /^-(.+)/) {
              $command = "grep '$1' tmp2";
            }
            @lines = `$command`;
            if($#lines >= 0) {
              next;
            } else {
              $ret = 1;
              if ($opt_d) { print "\nfailed to get result for $command \n"; }
            }
        }
        close TMP1;
        #the reverse
        open TMP2, '<', "tmp2";
        foreach my $line(<TMP2>) {
            chomp $line;
            $line =~ s/\'/\./g;
            my $command = "grep '$line' tmp1";
            if ($line =~ /^-(.+)/) {
              $command = "grep '$1' tmp1";
            }
            @lines = `$command`;
            if($#lines >= 0) {
              next;
            } else {
              $ret = 1;
              if ($opt_d) { print "\nfailed to get result for $command \n"; }
            }
        }
        close TMP2;
#       system("rm tmp1 tmp2");
        if($ret == 0) {print color 'bold green'; &printAll(-1, "PASS GOLD"); print color 'reset';}
        else {
            print color 'bold red'; &printAll(-1, "CRC FAIL"); print color 'reset';
            if($opt_f) {exit(1);}
            $exit_code = 1;
        }
    }
}

#unified print interface
sub printAll{
    foreach my $arg(@_) {
        if($arg == -1) {
            print PERFLOG "\t";
            print PERFCSV ",";
            print "\t";
        } 
        else {
            print PERFLOG $arg;
            print PERFCSV $arg;
            print $arg;
        }
    }
}

#Record the perf result to svn server
sub getDatabase{
    open DATABASE, '<', "$opt_i"; 
    my @lines = `grep use $opt_i`;
    my $database = "";
    foreach my $line(@lines) {
        if($line =~ /^\s*use\s+([a-zA-Z0-9_-]+)/) {$database = $1;}
    }
    $database;
}

#find the latest 3 perf numbers
sub findLatest {
    my $num = @_[0];
    my $idx = @_[1];
    my $i = 0;
    my @times;
    my @dirs = `find ./perf/ -name ${hostname}_${database}\* |sort -r`;
    foreach my $file (@dirs) {
        chomp $file;
        my @lines = `grep query$idx.sql $file/perf.log`;
            foreach my $line(@lines) {
                if($line =~ /query$idx.sql\s+(\d+)\s+/) {
                    $times[$i] = $1;
                    $i++;
                    if($i > $num) {return @times;}
                } 
          }
    }
    @times;
}
