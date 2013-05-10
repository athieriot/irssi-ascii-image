This script will intercept all messages (channel, and private) searching for URLs. 
If the URL is an image, it will convert it into an ASCII string.

Configuration options for this script include:
	expand_url_privmsgs	- A boolean which toggles whether private
				messages are searched or not.
	expand_url_white	- A string of whitespace delimited
				channels in which expansion is to take place.
				For example, '#news &twitter #shorturls'
				If this variable is left undefined, all
				channels are searched for shortened URLs.
				To reset, use /set -clear expand_url_white

I'm not sure that expand_url_white is really needed.

If you find any bugs, having any suggestions, or just want to chat, hit me up!
