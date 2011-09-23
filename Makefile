
default:
	# Set default make action here
	# xcodebuild -target MiniMusicalStarTests -configuration MyMainTarget -sdk iphonesimulator build	

clean:
	-rm -rf build/*

test:
	GHUNIT_CLI=1 xcodebuild -target MiniMusicalStarTests -configuration Debug -sdk iphonesimulator build	

