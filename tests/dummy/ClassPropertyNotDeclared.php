<?php

class ClassPropertyNotDeclared 
{
	
  private $param;

  protected $that;
	protected $thisandthat;
	
	public function doThis($param) {
		$this->this = 0;
	}

	public function doThat($param) {
		$this->that = 0;
	}

	public function doThisAndThat($param) {
	  $this->thisandthat = 0;
	}
}