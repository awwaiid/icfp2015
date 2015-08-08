#!/usr/bin/php
<?php


/*
 *
 * Input: json file of a Map with a unit in the final location 
 * Output: a score of that location on that map
 *
 * Process
 * sum of each row_score where
 * rowscore = RowNumber * %change_in_empties * (1+change_in_complexity) where
 * %change_in_empties = number_of_units_in_row/(number_of_empties+number_of_unties_in_row) and
 * $change_in_complexity = complexity_with_units_as_empties-complexity_with_unties_as_fulls where
 * 
 *
 */

/**
 * score a full map
 * PARAM $arr:t an array of arrays of U F and E's
 * RETRUN float the score for the map
 */
function score($arr) {
  $row_index=0;
  $row_scores = array_map(function($item, $key){
    return row_score($item)*($key+1);;
  },$arr, array_keys($arr));
  return array_sum($row_scores);

}
function row_score($row) {
  return change_in_empty($row)*(1+complexity_diff($row));
}
function change_in_empty($arr) {
  $counts = array_count_values($arr) + array("U"=>0, "E"=>0);
  $pre_empties = $counts['U'] + $counts['E'];
  if($pre_empties>0) {
    return $counts['U']/$pre_empties;
  }
  return 0;
}
function complexity_diff($arr) {
  return complexity_score(unit_to($arr, "F"))
       - complexity_score(unit_to($arr, "E"));
}
function complexity_score($arr) {
  return sqrt_of_sums(normalize_array(complexity_array($arr)));
}
function complexity_array($arr, $type='E') {
  $rtn = array();
  $last = "";
  $count = 0;
  foreach($arr as $item) {
    if($item !== $last) {
      if($last===$type) {
        $rtn[] = $count;
      }
      $count=0;
    }
    $last = $item;
    $count++;
  }
  if($count>0 && $last===$type) {
    $rtn[] =$count;
  }
  return $rtn;
}

function unit_to($arr,$to, $from="U") {
  return array_map(function($item) use ($to, $from) {
    return $item === $from ? $to : $item;
  },$arr);
}

function sqrt_of_sums($arr) {
  return sqrt(array_sum(array_map(function($item) {return $item*$item;},$arr)));
}
function normalize_array($arr) {
  $total = array_sum($arr);
  return array_map(function($row) use ($total) {
    return $row/$total;
  }, $arr);
}

$arr = array(
  array("E","E","E","E"),
  array("E","U","F","E"),
  array("U","U","F","E"),
);

while ($line = trim(fgets(STDIN))) {
  $map = json_decode($line,TRUE);
  print_r($map);
  print score($map) . "\n";
}
