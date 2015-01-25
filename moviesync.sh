#!/bin/bash

# Variables
MOVIES='/mnt/nas/media/movies/en'
NUC='/mnt/nuc/en_movies'

# Get the lists
cd $MOVIES
du -h -s * > /tmp/Movies.txt
cd $NUC
du -h -s * > /tmp/Nuc.txt

cd /tmp
# Sort the lists
cat Nuc.txt | sort > Nuc_sorted.txt
cat Movies.txt | sort > Movies_sorted.txt

# Compare the two files
COMPARE=$(cd /tmp; diff 'Movies_sorted.txt' 'Nuc_sorted.txt')

# Look if we have movies on the nas that are not on the nuc. <
TOSYNC=$(echo "$COMPARE" | grep '<')

# Check if we need to sync some movies and if yes do it!
if [ -z "$TOSYNC" ]
then
# Implement propper logging here!
# We just expect that new movies on the nas go into the MOVIES folder.
		echo "No movies on the NAS that are not on the NUC."
else
		echo 'The following movies are ONLY available local:'
		echo "$TOSYNC"
		echo 'Starting rsync to NUC:'
		# Loop over the movies we need to sync.
		while read -r line; do
    			NAME=$(echo "$line" | awk '{$1=$2=""; print $0}' | sed -e 's/^ *//' -e 's/ *$//')
			rsync -rvz --progress "$MOVIES/$NAME" "$NUC"
		done <<< "$TOSYNC"
fi


# Now we check if we have movies that are only on the nuc.
TOSYNC=$(echo "$COMPARE" | grep '>')
if [ -z "$TOSYNC" ]
then
	echo "No movies on the NUC that are not on the NAS."
else
	 echo 'The following movies are ONLY available at the remote site:'
	 echo "$TOSYNC"
	 echo 'Starting rsync to NAS:'
	 # Loop over the movies we need to sync.
	 while read -r line; do
		NAME=$(echo "$line" | awk '{$1=$2=""; print $0}' | sed -e 's/^ *//' -e 's/ *$//')
		rsync -rvz --progress "$NUC/$NAME" "$MOVIES" 
	done <<< "$TOSYNC"
fi

# Remove temp files here.
rm /tmp/Movies.txt
rm /tmp/Nuc.txt
rm /tmp/Nuc_sorted.txt
rm /tmp/Movies_sorted.txt
