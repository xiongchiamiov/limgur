# limgur

CLI to Imgur, letting you upload and delete images.

If you've got scrot installed, you can also take a screenshot and upload it in one command.

## Usage

    Usage: limgur [options]
        -u, --upload                     Upload via image or URL
        -d, --delete                     Delete an image via hash
        -s, --scrot                      Take a screenshot then upload it
        -h, --help                       Show this message
        -v, --version                    Show version

## TODO

* Allow scrot'n to a directory without specifying a filename (eg. limgur -s ~/images/)
* Accept scrot options while scrot'n (eg. limgur -s -c -d 3 ~/images/wat.png)

## Copyright

Copyright (c) 2009 Danny Tatom. See LICENSE for details.
