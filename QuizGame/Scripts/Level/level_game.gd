extends Node

enum QuestionType {TEXT, IMAGE, VIDEO, AUDIO}

export (Resource) var bd_quiz # acesso ao banco de dados
export (Color) var color_right
export (Color) var color_wrong

var buttons := [] # como precisamos de um array c todos os botoes, declaramos essa var
var index :=0  # index é indice, no caso a representa a pergunta atual do meu banco de dados
var quiz_shuffle := []
var correct := 0

onready var question_texts := $question_info/txt_question
onready var question_image := $question_info/Panel/question_image
onready var question_video := $question_info/Panel/question_video
onready var question_audio := $question_info/Panel/question_audio

func _ready() -> void:
	for _button in $question_holder.get_children(): #fazendo uma interação dentro dos buttons do nó quesiton holder
		buttons.append(_button) # adiciona os botões filhos do nó
	
	quiz_shuffle=randomize_array(bd_quiz.bd)
	load_quiz()

func load_quiz() -> void:
	
	if index >= bd_quiz.bd.size():
		print("Acabaram as perguntas")
		game_over()
		return # comando para sair da função
	
	question_texts.text = str(quiz_shuffle[index].question_info) # declarando que question_text vai receber a var bd do nosso bd_quiz, precisamos declarar qual o item e fazemos pelo index, depois pegamos o texto através da question_info definada no script "res_question" que exporta as variaves das perguntas
	
	var options = randomize_array(bd_quiz.bd[index].options)
	
	for i in buttons.size():
		buttons[i].text=str(options[i]) # preenchendo os buttons com as options ou alternativas
		buttons[i].connect("pressed", self, "buttons_answer", [buttons[i]]) # criando o sinal pressed nesse mesmo scrpit, com a func buttons_answer, passando o próprio botão como argumento
		
	match bd_quiz.bd[index].type:
		QuestionType.TEXT: # se o question type for texto, escona o panel
			$question_info/Panel.hide()
		
		QuestionType.IMAGE: # se o question type for imagem, habilita o panel
			$question_info/Panel.show()
			question_image.texture=bd_quiz.bd[index].question_image
			
		QuestionType.VIDEO: # se o question type for imagem, habilita o panel
			$question_info/Panel.show()
			question_video.strem=bd_quiz.bd[index].question_video
			question_video.play()
			
		QuestionType.AUDIO: # se o question type for video, habilita o panel
			$question_info/Panel.show()
			# question_image.texture=load("res arquivo que eu quiser")
			question_audio.stream=bd_quiz.bd[index].question_audio
			question_audio.play()
			
func buttons_answer(button) -> void:
	print(button.text)
	if bd_quiz.bd[index].correct == button.text:
		button.modulate = color_right
		correct += 1
	else:
		button.modulate = color_wrong
		
	question_audio.stop() # para a reprodução se n fica repetindo
	question_video.stop()
	
	yield (get_tree().create_timer(1), "timeout") # criando temporizador de 1 s, para continuar o processo
	for bt in buttons: # para cada bt em buttons a gnt vai pegar o modulate e voltar para o padrão
		bt.modulate=Color.white
		bt.disconnect("pressed", self, "buttons_answer")
	
	question_audio.stream=null # apenas apra evitar bugs
	question_video.stream=null
	index +=1 # quando ele responder, ele irá para a outra pergunta
	load_quiz()
	
func randomize_array(array: Array) -> Array: #funcao para randomizar um array
	randomize()
	var array_temp := array #criando var temporario para receber o array
	array_temp.shuffle()
	return array_temp # retornando o array randozmizado

func game_over() -> void:
	$game_over.show()
	$game_over/txt_result.text=str(correct, "/", bd_quiz.bd.size())


func _on_button_restart_pressed():
	get_tree().reload_current_scene()
