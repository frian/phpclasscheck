<?php

class ClassParameterNotDeclared 
{

	protected $this;
	protected $that;

	protected $iterations;
	
	protected function doThis($iterations) {
		$this->this = 0;
	}

	protected function doThat($duration) {
		$this->that = 0;
	}	
}