#!/bin/sh
_TABLE=138
if [ "$TABLE" ]; then
  _TABLE=$TABLE
fi
_FILTER=./idgxmlfilter.rb
if [ "$FILTER" ]; then
  _FILTER=$FILTER
fi
_OUTPUT=.
if [ "$OUTPUT" ]; then
  _OUTPUT=$OUTPUT
fi

for re in $(grep -v "#" catalog.yml | grep ".re" | sed -e "s/.*\- //"); do
  if [ -z "$TARGET" ] || [ "$TARGET" = "$re" ]; then
    echo "compiling $re"
    review compile --target=idgxml --table=$_TABLE $re |\
      $_FILTER > $_OUTPUT/$(basename $re .re).xml
  else
    echo "skip $re"
  fi
done
echo "Done."
