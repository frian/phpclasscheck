<?php

class ClassPropertyNotDeclared 
{
	
	protected $that;
	
	public function doThis() {
		$this->this = 0;
	}

	public function doThat() {
		$this->that = 0;
	}	
}