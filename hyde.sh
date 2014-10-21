#! /bin/bash

# Configuration #
export JEKYLL_DIR="/Users/orion/developer/sites/fmscode.github.io/_posts"
export MICRO_POST_LENGTH=240

# Function: version
# Description: Current version information
#
version(){
	cat <<-EndVersion
		Hyde

		Version: 0.1
		Original conception by: Frank Michael Sanchez
		License: MIT, http://choosealicense.com
	EndVersion
}

# Function: addPost
# Parameters: $1: Filename
#			  $2: Template name, Optional
#			  $3: Post Title 
# Description: Creates a new post in the _posts directory
#
addPost(){
	currentDate=`date +%Y-%m-%d`
	fullDateTime=`date +%Y-%m-%d' '%T' UTC'`
	postContent="---
layout: $2
title: $3
date: $fullDateTime
---"
	cat <<EOF > $(postsDirectory)/$currentDate-$1.md
$postContent
EOF
	open "$(postsDirectory)/$currentDate-$1.md"
}


# Function: addMicroPost
# Parameters: $1: FileName
#			  $2: Content
#			  $3: Link, Optional
# Description: Function to add a new micro post
#
addMicroPost(){
	# Time/date for post
	currentDate=`date +%Y-%m-%d`
	fullDateTime=`date +%Y-%m-%d' '%T' UTC'`
	# Basic post content
	postContent="---
layout: post
title: $1
date: $fullDateTime
tags: micropost
---
$2"
	# Check if a link was passed with this post
	if [ ${#3} -ne 0 ]; then
	postContent="$postContent 

	[$3]($3)"
	fi
# Create file
	cat <<EOF > $(postsDirectory)/$currentDate-$1.md
$postContent
EOF
}

# Function: checkPostDirectory
# Description: Checks if the current location contains the _posts Jekyll directory
#
checkPostsDirectory(){
	if [ ${#JEKYLL_DIR} -ne 0 ]; then
		if [ ! -d "$JEKYLL_DIR" ]; then
			echo "Invalid Jekyll Posts location"
			exit;
		fi
	else
		# Check if _posts directory exists.
		if [ ! -d "${PWD}/_posts" ]; then
			echo "$(tput setaf 1)Posts directory was not found!$(tput sgr0) Please make sure you are in the Jekyll directory."
			exit;
		fi
	fi
}

# Function: postsDirectory
# Description: Returns the Jekyll _posts directory or whichever directory used for JEKYLL_DIR.
#
postsDirectory(){
	if [ ${#JEKYLL_DIR} -ne 0 ]; then
		echo $JEKYLL_DIR
	else
		echo "${PWD}/_posts"
	fi
}

# Function: scriptHelp
# Parameters: $1: Action command, Optional
# Description: The help output with action support
#
scriptHelp(){
	case $1 in
		"post" )
			cat <<-EndAddHelp
			  Usage: post "[title]" [options]
			  Action: post|add
			  Options:
				    title: Post Title
				    -l: Post Layout
			EndAddHelp
		;;
		"micro" )
			cat <<-EndMicroHelp
			  Action: micro
			  Usage: micro "[content]" [options]
			  Options:
				    content: The content of the micro post.
				    -l: A micropost link
			EndMicroHelp
		;;
		"view" )
			cat <<-EndViewHelp
			  Action: view
			  Description: Opens the _posts directory
			EndViewHelp
		;;
		* )
			cat <<-EndHelp
			  Usage: hyde [action] [options]

			  Actions:
				    post|add "A new post to be added"
				    micro "A new micropost"
				    view "Opens the _posts directory"
			  
			  'hyde help [action]' for help on the action
			EndHelp
		;;
	esac
	exit 0
}

# Begin Script
# Read in the action from the user
action=$1
# Shift to the options parameters
shift 1
# Logic for each action
case $action in
	"post" )
		checkPostsDirectory
		# Post title is given
		postTitle=$1
		# File name is the post title without any space characters
		fileName=`echo "$postTitle" | tr ' ' '-'`
		shift;
		# Read in the options that the add Action supports
		while getopts "l:" Option
			do
				case $Option in
					'l' )
						# Defines the layout the post to use, used for Jekyll templates
						layout=$OPTARG
					;;
				esac
		done
		# Check post title length
		if [ ${#postTitle} -eq 0 ]; then
			echo "Invalid post title"
			exit;
		fi
		# Set default for the layout if layout is not set
		if [ ${#layout} -eq 0 ]; then
			layout=post
		fi
		# Create post file
		addPost "$fileName" "$layout" "$postTitle"
	;;
	"micro" )
		checkPostsDirectory
		# Use current time as post title
		cTime=$(date +"%T")
		cTime=`echo "$cTime" | tr -d ':'`
		fileName="$cTime"
		# Check the length of the post to be MICRO_POST_LENGTH
		postContent=$1
		postContentLength=${#postContent}
		if [ $postContentLength -eq 0 ]; then
			echo "$(tput setaf 1)Invalid post!$(tput sgr0)"
		else
			if [ $postContentLength -gt $MICRO_POST_LENGTH ]; then
				# Ouput the post and show the user where 240 characters end.
				echo "$(tput setaf 1)Invalid post length$(tput sgr0)"
				echo "${postContent:0:240}$(tput setaf 1)${postContent:240}$(tput sgr0)"
				exit;
			else
				shift
				# Read in the options that the micro Action supports
				while getopts "l:" Option
					do
						case $Option in
							'l' )
								# Post title is given
								link=$OPTARG
							;;
						esac
				done
				# Create micro post
				addMicroPost "$fileName" "$postContent" "$link"
			fi
		fi
	;;
	"view" )
		open "$(postsDirectory)"
		exit;
	;;
	"version" | "v" )
		version
	;;
	"help" )
		scriptHelp "$1"
	;;
	* )
		echo "Invalid Command"
	;;
esac

