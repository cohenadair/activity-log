if [ ! -z "$1" ];
then
    flutter build ios
    flutter build apk
    cp build/app/outputs/apk/release/app-release.apk ~/Drive/projects/activity-log/activity-log_$1.apk
else
    echo "Usage: build_release <version>"
fi