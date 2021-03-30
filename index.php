 
<!DOCTYPE html>
<html>
	<head>
		<title>PhpSA</title>
	</head>

<body>
	<nav></nav>
	<?php
	require_once('model.php');


	#Parâmetros
	$validate = true;
	$validate = false;

    $param =  [
				"Data"=>"01-01-2004",
				"Texto"=>"teste testes",
				"Checkbox"=>"on",
				"Texto_Grande"=>"T3STE TES13"
				];
	#$param=[];



	$Comp_Formulario = new UI_Comp_Formulario($validate);

 
	if(isset($_POST) && !empty($_POST)){ 

		if($Comp_Formulario->validate()==true)
		{
			echo "Formulário Válido!";
		}
		else{
			echo "Formulário Inválido!";
		}

	$param =  [
				"Data"=>$_POST["Data"],
				"Texto"=>$_POST["Texto"],
				"Checkbox"=>!isset($_POST["Checkbox"])?"":"checked",
				"Texto_Grande"=>$_POST["Texto_Grande"]
				];	

				 

	}

 
	?>
	
	<div style="margin:5rem 5rem;display: grid;background: whitesmoke;padding: 2rem">
		<form name='form' id='form' method='post' action="" >
			<fieldset>
				<?php
				
						 
				echo $Comp_Formulario->renderer(
					$param
						);
				?>
				<!--
				<div style="margin-top:1rem"><label>Data</label><input type="" name="Data" class='data' style="position:absolute;left: 25rem"></div>
				<div style="margin-top:1rem"><label>Texto</label><input type="" name="Texto" class='texto' style="position:absolute;left: 25rem"></div>
				<div style="margin-top:1rem"><label>Checkbox</label><input type="checkbox" name="Checkbox" style="position:absolute;left: 25rem"></div>
				<div style="margin-top:1rem"><label>Texto Grande</label><textarea class='textoGrande' name="Texto Grande" style="position:absolute;left: 25rem"></textarea></div>
				-->
				<div style="margin-top:2rem"><label>Submit</label><input type="button" name="Submit" value="Submit" style="position:absolute;left: 25rem" onclick="<?=$Comp_Formulario->validateScript?"checkForm()":"formSubmit()"?>"></div>
			</fieldset>
		</form>
	</div>
	

</body>

<script type="text/javascript">


	function formSubmit(){
		let form = document.getElementById('form');
		form.submit()

	}
	
	function checkForm() {

		let form = document.getElementById('form')

		let data = form.getElementsByClassName('data')[0].value
		let datas_ok  = (data[2]==data[5]) && (data[2]=='-') 
		&& 
		(data[0]+data[1]+data[3]+data[4]+data[6]+data[7]+data[8]+data[9]).replace(/[0-9]/ig,'')=="" 

 		 
		let texto = form.getElementsByClassName('texto')[0].value
		let textos_ok =  texto.length>0 && texto.length<=144 && texto.toLowerCase()==texto && texto.replace(/[ A-Za-zÀ-ÖØ-öø-ÿ]/ig, '')==""


		let textoGrande = form.getElementsByClassName('textoGrande')[0].value
		let textosGrande_ok = textoGrande.length>0 && textoGrande.length<=255 && textoGrande.toUpperCase()==textoGrande && textoGrande.replace(/[ 0-9A-Za-zÀ-ÖØ-öø-ÿ]/ig, '')==""

		let msg = ''
		if(!datas_ok){msg +='Formato de data inválido!\n';}
		if(!textos_ok){msg +='Formato do texto inválido!\n';} 
		if(!textosGrande_ok){msg +='Formato do texto grande inválido!\n';}	
		console.log(msg);
 
		if(msg==''){
			formSubmit();
		}
		else
		{
			alert(msg);
		}
	}
</script>

</html>


