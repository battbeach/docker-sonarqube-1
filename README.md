# sonarqube-mod

This image is based on the official image for sonarqube, but allows for automatic plugin installation based on a URL or a list of plugins.

You control the installed plugins using environment variables:

* `PLUGINLIST` - contains a list of plugins to be installed
* `PLUGINLIST_URL` - contains a URL which is fetched

You can set both.

The structure of the data (if as file on the given `$PLUGINLIST_URL` or as string in `$PLUGINLIST`) is as follows:

    # this is a comment
    URL FILENAME[.jar]

    # empty lines are ignored
    URL2 FILENAME2[.jar]

or

    URL1 FILENAME1 ; URL2 FILENAME2

The URL is then downloaded as `$FILENAME.jar` in the sonarqube plugins directory. The reason for the filename is that if you upgrade the plugin (from v1.0 to v1.1 for example), it will get saved as the same file name and overwrite the previous version, which is required by sonarqube.

Done.
