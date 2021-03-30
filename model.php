<?php

class UI_Comp_Formulario { 
    public $validateScript ;
   
   
    function __construct($validateScript=false) {
    	$this->validateScript=$validateScript; 
    }

    public function renderer($param=false)  {
        
        	if(!$param){
	        	$param=[
	        	 "Data"=>"",
				 "Texto"=>"",
				 "Checkbox"=>"",
				 "Texto_Grande"=>""
				];
        	}


        	$checked = $param["Checkbox"]=="checked"?"checked":"";

	        return  
					'<div style="margin-top:1rem"><label>Data</label><input type="" name="Data" value="'.$param["Data"].'" class="data" style="position:absolute;left: 25rem"></div>'.
					'<div style="margin-top:1rem"><label>Texto</label><input type="" name="Texto" value="'.$param["Texto"].'" class="texto" style="position:absolute;left: 25rem"></div>'.
					'<div style="margin-top:1rem"><label>Checkbox</label><input type="checkbox" name="Checkbox" 
					 value="'.$checked.'" '.$checked.'  style="position:absolute;left: 25rem"></div>'. 
					'<div style="margin-top:1rem"><label>Texto Grande</label><textarea class="textoGrande" name="Texto_Grande"  style="position:absolute;left: 25rem">'.$param["Texto_Grande"].'</textarea></div>';
					 
				 
		
    }

     public function validate() {

     	

      	 $texto_grande = $_POST["Texto_Grande"];
     	 $texto = $_POST["Texto"];
     	 $data = $_POST["Data"];

     	 $msg = '';

     	 preg_match('/[ 0-9A-Za-zÀ-ÖØ-öø-ÿ]+/',$texto_grande , $TextoGrandeMatches);
     	 $texto_grande_ok = sizeof($TextoGrandeMatches)==1 && 
     	 	$TextoGrandeMatches[0]==$texto_grande &&
     	 	strtoupper($texto_grande)==$texto_grande &&
     	 	strlen($texto_grande)<255
     	 	  ;
     	  if(!$texto_grande_ok)
     	 	$msg.='Formato de texto grande inválido!'.'<br />';



     	 preg_match('/[ A-Za-zÀ-ÖØ-öø-ÿ]+/',$texto, $TextoMatches);
     	 $texto_ok = sizeof($TextoMatches)==1 && 
     	 	$TextoMatches[0]==$texto &&
     	 	strtolower($texto)==$texto &&
     	 	strlen($texto)<144
     	 	  ;
     	 if(!$texto_ok)
     	 	$msg.='Formato de texto inválido!'.'<br />';

  
 		$data_ok=false;
		$data_partes = explode('-',$data);	
		if(sizeof($data_partes)==3) 
     		$data_ok = checkdate($data_partes[1], $data_partes[0], $data_partes[2]) ;
     	else
     		$msg.='Formato de data inválido!'.'<br />';


     	echo $msg; 
     	 
     	return $data_ok && $texto_grande_ok && $texto_ok;

     	
     }
}

