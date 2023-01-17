#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

DETERMINE_TYPE()
{
  TYPE=$($PSQL "select type from types inner join properties using(type_id) where atomic_number=$ATOMIC_NUMBER")
  #echo "The type is:" $TYPE
}

GET_DATA_FROM_PROPERTIES() 
{
  #echo "In get_data_from_properties function"
  DATA_FROM_PROPERTIES=$($PSQL "select atomic_mass,melting_point_celsius,boiling_point_celsius from properties where atomic_number=$ATOMIC_NUMBER")

  echo "$DATA_FROM_PROPERTIES" | while read ATOMIC_MASS BAR MELTING_POINT BAR BOILING_POINT
  do
    echo "The element with atomic number" $ATOMIC_NUMBER "is" $NAME "("$SYMBOL")". "It's a" $TYPE", with a mass of" $ATOMIC_MASS "amu." $NAME "has a melting point of" $MELTING_POINT "celsius and a boiling point of" $BOILING_POINT "celsius."
  done
}

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ATOMIC_NUMBER=$1
    #echo "the atomic_number is:" $ATOMIC_NUMBER
    DATA_FROM_ELEMENTS=$($PSQL "select name, symbol from elements where atomic_number=$ATOMIC_NUMBER")
      if [[ -z $DATA_FROM_ELEMENTS ]]
      then
        echo "I could not find that element in the database."
      else
        #echo "Data from elements by atomic_number:" $DATA_FROM_ELEMENTS
        echo "$DATA_FROM_ELEMENTS" | while read NAME BAR SYMBOL
          do
          #echo "Name1 is: " $NAME
          #echo "Symbol is: " $SYMBOL
          DETERMINE_TYPE
          GET_DATA_FROM_PROPERTIES
          done
      fi
  else
    _LEN=${#1}
    #echo "Length is:" $_LEN
    if [[ $_LEN -lt 3 ]]
    then
      SYMBOL=$1
      #echo "the screen input symbol is:" $SYMBOL
      DATA_FROM_ELEMENTS=$($PSQL "select atomic_number, name from elements where symbol='$SYMBOL'")
        if [[ -z $DATA_FROM_ELEMENTS ]]
        then
          echo "I could not find that element in the database."
        else
          #echo "Data from elements by symbol:" $DATA_FROM_ELEMENTS
          echo $DATA_FROM_ELEMENTS | while read ATOMIC_NUMBER BAR NAME
          do
            #echo "***atomic number is:" $ATOMIC_NUMBER
            DETERMINE_TYPE
            GET_DATA_FROM_PROPERTIES
          done
        fi
    else
      NAME=$1
      #echo "the screen input name is:" $NAME
      DATA_FROM_ELEMENTS=$($PSQL "select atomic_number, symbol from elements where name='$NAME'")
        if [[ -z $DATA_FROM_ELEMENTS ]]
        then
          echo "I could not find that element in the database."
        else
          #echo "Data from elements by name:" $DATA_FROM_ELEMENTS
          echo "$DATA_FROM_ELEMENTS" | while read ATOMIC_NUMBER BAR SYMBOL
          do
            DETERMINE_TYPE
            GET_DATA_FROM_PROPERTIES
          done
        fi
    fi
  fi
fi

