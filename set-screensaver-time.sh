#!/bin/sh
# Set the screesaver password time for Snow Leopard (10.6.x)

# Detail:  http://www.macosxhints.com/article.php?story=20090831053120918
#
# To set it to however long you like, edit the last item (1800, 
# which is 30 minutes * 60 seconds/minute) to the desired delay in seconds.

# Set screensaver password activation to be 30 minutes

defaults -currentHost write com.apple.screensaver askForPasswordDelay -int 1800
