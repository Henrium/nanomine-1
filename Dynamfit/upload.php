<?php
$target_dir = "/home/NANOMINE/Develop/mdcs/Dynamfit/media/";
$target_file = $target_dir.basename($_FILES["datafile"]["name"]);
move_uploaded_file($_FILES["datafile"]["tmp_name"], $target_file);
?>
