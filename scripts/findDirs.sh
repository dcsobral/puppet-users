#!/bin/bash

for dir in "$@"
do
	ls -d "$dir" 2>/dev/null
done

exit 0

