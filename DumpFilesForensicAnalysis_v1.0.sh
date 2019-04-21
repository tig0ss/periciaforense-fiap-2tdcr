#!/bin/bash

# name:   DumpFilesForensicAnalysis_v1.0.sh
# since:  2019-04-20 - Brazil
# author: Tiago S. de Santana

#### FUNCOES

# Esta funcao prepara o local onde sera armazenado as evidencias
function preparaDirEvidencias () {
	lsblk

	echo " "

	echo "Deseja montar alguma particao para salvar as evidencias? (S/N)"
	read resp_Mount;

	echo " "

	if [ $resp_Mount == "S" ] || [ $resp_Mount == "s" ];
	then
		echo "Informe a particao que deseja montar: (Exemplo: sdb2) "
		read part_Mount;

		echo " "

		echo "Particao escolhida:"
		ls /dev/$part_Mount

		while [ $? != "0" ];
		do
        		echo " "
		        echo "!!! - Particao inválida! informe a particao que deseja montar (Exemplo: sdb2): "
        		echo " "
        		lsblk
        		read part_Mount;
		        echo "Particao escolhida:"
		        ls /dev/$part_Mount
		done

		echo " "

		echo "Informe o ponto de montagem da particao: (Exemplo: /mnt ou /media/user)"
		read ponto_Mount;
		while [ ! -d $ponto_Mount ];
		do
			echo "!!! - Ponto de montagem inválido! Informe o ponto de montagem da particao (Exemplo: /mnt ou /media/user): "
			read ponto_Mount;
		done

		echo " "

		mount /dev/$part_Mount $ponto_Mount 

		echo " "

		cd $ponto_Mount

		echo "Diretorio acessado:"
		pwd

		echo " "

		echo " "
		echo "Deseja criar uma pasta neste diretorio para salvar as evidencias coletadas? (S/N)"
		read resp_MakeDir
		echo " "

		if [ $resp_MakeDir == "S" ] || [ $resp_MakeDir == "s" ];
		then
			echo "Por favor, informe o nome do diretor de evidencias que sera criado: "
			read dir_MakeDir

			echo " "
			mkdir $dir_MakeDir

			# Melhoria futura: incluir verificacao se o diretorio foi criado com sucesso
			echo "Diretorio criado!"
			cd $dir_MakeDir
			pwd
			echo " "
		else
			echo "Neste caso as evidencias coletadas serao salvas em: "
			pwd
		fi

		echo " "

		lsblk

		echo " "

		lsusb

		echo " "

	else
		echo "Para salvar as evidências sera necessario utilizar um diretorio valido!"
		echo "Por favor, informe um diretorio valido para que isso seja possivel (Exemplo: /home/user): "
		read dir_Valid
		while [ ! -d $dir_Valid ];
		do
			echo " "
			echo "!!! - Diretorio informado nao existe. Por favor informe um diretorio valido (Exemplo: /home/user): "
			read dir_Valid
		done

		cd $dir_Valid

		echo " "
		echo "Deseja criar uma pasta neste diretorio para salvar as evidencias coletadas? (S/N)"
		read resp_MakeDir
		echo " "

		if [ $resp_MakeDir == "S" ] || [ $resp_MakeDir == "s" ];
		then
			echo "Por favor, informe o nome do diretor de evidencias que sera criado: "
			read dir_MakeDir

			echo " "
			mkdir $dir_MakeDir

			# Melhoria futura: incluir verificacao se o diretorio foi criado com sucesso
			echo "Diretorio criado!"
			cd $dir_MakeDir
			pwd
			echo " "
		else
			echo "Neste caso as evidencias coletadas serao salvas em: "
			pwd
		fi

	fi
}

# Esta funcao executa os primeiros comandos para evidenciar a neutralidade do ambiente que sera trabalhado
function coletaEvidPreAnalise () {

echo " "
echo "**** Iniciando a coleta de evidencias pre Objeto Questionado. Aguarde...  ****"
sleep 2
echo " "

echo "Versao do Sistema Operacional utlizado para a pericia:"
cat /etc/os-release >> os-release.txt
lsb_release -a >> os-release.txt
cat os-release.txt
echo " "

echo "Data e hora da coleta de evidencias: "
date | tee dateInicioPericia.txt
echo " "

echo "Lista dos dispositivos de bloco disponiveis: "
lsblk | tee lsblk1.txt
echo " "

echo "Lista de todas as particoes montadas: "
df -hT | tee df1.txt
echo " "

echo "Lista de dispositivos USB disponiveis: "
lsusb | tee lsusb1.txt
echo " "

}

# Esta funcao coleta as evidencias sobre a integridade do Objeto Questionado
function coletaEvidOB () {

echo " "
echo "**** Iniciando a coleta de evidencias do Objeto Questioando ****"
echo " "

echo "Por favor, insira o Objeto questionavel em uma porta USB e pressione <Enter>. "
read

# Melhoria futura: encontrar funcao que identifique se algum dispositivo USB foi plugado
echo "Por favor, aguarde... "
echo " "
sleep 4

echo "Lista dos dispositivos de bloco disponiveis: "
lsblk | tee lsblk2.txt
echo " "

echo "Lista de todas as particoes montadas: "
df -hT | tee df2.txt
echo " "

echo "Lista de dispositivos USB disponiveis: "
lsusb | tee lsusb2.txt
echo " "

echo "Por favor, informe o id do Objeto Questionado, apresentado na lista acima (Exemplo: 80ee:0021) : "
read id_ObjeQuest
echo " "

echo "Coleta informacoes especificas do Objeto Questionado: "
lsusb -v -d $id_ObjeQuest | tee lsusb-details1.txt

while [ $? != "0" ];
do
	echo "!!! USB ID invalido."
	echo "Por favor, informe o id do Objeto Questionado, apresentado na lista acima (Exemplo: 80ee:0021) : "
	read id_ObjeQuest
	echo " "

	lsusb -v -d $id_ObjeQuest | tee lsusb-details1.txt
done

}

# Esta funcao gera o DUMP do Objeto Questionado para coleta de evidencias para analise forense
function geraDumpOQ () {

echo " "
echo "**** Gerar dump do Objeto Questioando ****"
echo " "

echo "Lista dos dispositivos de bloco disponiveis: "
lsblk | tee lsblk3.txt
echo " "

echo "Por favor, informe qual dispositivo de bloco deseja realizar o DUMP (Exemplo: /dev/sdb): "
read disp_OQDump
echo " "
echo "O Objeto Questionado informado foi: "
ls $disp_OQDump

while [ $? != "0" ];
do
	echo " "
	echo "!!! Objeto Questionado informado invalido."
	echo "Por favor, informe qual dispositivo de bloco deseja realizar o DUMP (Exemplo: /dev/sdb): "
	read disp_OQDump
	echo " "
	echo "O Objeto Questionado informado foi: "
	ls $disp_OQDump
	echo "Aguarde..."
	sleep 2
done

dcfldd if=$disp_OQDump of=DumpOB.raw hash=md5,sha1 hashlog=hash-raw.txt

# Gerando as hashes do Objeto Questionado para comparar com o Dump gerado e garantir a integridade

echo " "

echo "Gerar hash MD5 do Objeto Questionado"
md5sum $disp_OQDump >> hash-OQ.txt
echo " "

echo "Gerar hash SHA1 do Objeto Questionado"
sha1sum $disp_OQDump >> hash-OQ.txt
echo " "

#Deleta linhas em branco do arquivo de hash da DUMP para comparar
awk 'NF>0' hash-raw.txt > hash-raw1.txt

diff -y hash-raw1.txt hash-OQ.txt

#Copia apenas as hashes para um compare mais efetivo
echo " "
echo "Copiando apenas as hashes para automatizar a comparacao: "
awk -F " " '{print $3}' hash-raw1.txt > hash-compare-raw.txt
awk -F " " '{print $1}' hash-OQ.txt > hash-compare-OQ.txt

echo " "
echo " "
echo "Resultado do compare: "
diff -s hash-compare-raw.txt hash-compare-OQ.txt

echo " "
}

#### CODIGO PRINCIPAL

#inicializa a execucao do codigo principal
echo "Deseja analisar um dispositivo? (S/N)"
read resp_Analysis
echo " "
echo " "

if [ $resp_Analysis == "s" ] || [ $resp_Analysis == "S" ];
then
	echo "Iniciando analise do Objeto Questionado:"
	# Esta funcao prepara o local onde sera armazenado as evidencias
	preparaDirEvidencias

	# Esta funcao executa os primeiros comandos para evidenciar a neutralidade do ambiente que sera trabalhado
	coletaEvidPreAnalise

	# Esta funcao coleta as evidencias sobre a integridade do Objeto Questionado
	coletaEvidOB

	# Esta funcao gera o DUMP do Objeto Questionado para coleta de evidencias para analise forense
	geraDumpOQ

	# salvar informacoes dos arquivos de evidencias salvos
	ls -lht | tee ls-lht1.txt

	echo "Automatizacao para geracao das evidencias finalizada! Obrigado!"
	exit
else
	echo "Tchau!"
fi

#echo "Informe o dispositivo que deseja realizar a analise forense: "
#read dir_Analysis

#if [ ! -d $dir_Analysis ]
#then
#	echo "Diretorio valido"
#else
#	echo "Diretorio invalido"
#fi

#ls -lh $dir_Analysis

#a variavel de sistema $? verifica o retorno do ultimo comando realizado, onde 0 é com sucesso
