<?php

class ClassPropertyNotDeclared 
{
	
	protected $that;
	
	function doThis() {
		$this->this = 0;
	}

	function doThat() {
		$this->that = 0;
	}	
}