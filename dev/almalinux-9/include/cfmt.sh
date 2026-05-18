#!/bin/sh
echo "Formatting C++ code in" $(pwd)
suff=".$$.reformatted"
dofmt() {
	if [ -f $1 ]; then
		out=$1.$suff
		if clang-format --fail-on-incomplete-format $1 > $out; then
			if cmp -s $1 $out; then
				rm "$out"
			else
				echo "Updated $1"
				diff -w -U 1 "$1" "$out"
				mv "$out" "$1"
			fi
		else
			echo "FAILED formatting $1"
			rm "$out"
		fi
	fi
}
for fn in $(find . -name '*.h' -o -name '*.hpp' -o -name '*.cpp')
do
	dofmt $fn &
done
wait
