
all: target/lib/dsdgen.jar target/tpcds-gen-1.0-SNAPSHOT.jar

target/tpcds-gen-1.0-SNAPSHOT.jar: $(shell find -name *.java) 
	mvn package

target/DSGen_v1.1.0.zip: DSGen_v1.1.0.zip
	mkdir -p target/
	cp DSGen_v1.1.0.zip target/DSGen_v1.1.0.zip

DSGen_v1.1.0.zip:
	#curl --output DSGen_v1.1.0.zip http://www.tpc.org/tpcds/dsgen/dsgen-download-files.asp?download_key=NaN
	curl --output DSGen_v1.1.0.zip http://50.57.156.74/tpcds/dsgen/dsgen-download-files.asp?download_key=NaN

target/lib/dsdgen.jar: target/tools/dsdgen
	cd target/; mkdir -p lib/; ( jar cvf lib/dsdgen.jar tools/ || gjar cvf lib/dsdgen.jar tools/ )

target/tools/dsdgen: target/DSGen_v1.1.0.zip
	test -d target/tools/ || (cd target; unzip DSGen_v1.1.0.zip; cd tools; cat ../../*.patch | patch -p0 )
	cd target/tools; make clean; make dsdgen

clean:
	mvn clean
