# Path Constructor

## English description
Program to automatically create paths for X - Ray Engine 1.6.00 - 02.

About the authors:

Leonid Kushnaryov - algorithm for generating paths from read coordinates

I, [Daniil Borchev](https://github.com/daniilborschev) - an algorithm for copying and assembling spawn according to a given location

## Program
To work correctly, the program requires
* To get the path, install the script into the game and use. Script description later
* Configure the path to the game (this folder will be searched for fsgame, which will contain the log file)
* Configure the path to the spam folder
* The program, if there is a log file in the specified folder, loads information about new paths into the output window itself.
* To reload the paths from the log file (for example, when overwriting this file), click the "Reload log file" button
* Click the button "Copy sections in spawn", and wait for the copy operation to complete
* At the end of the copying, the program will offer to assemble a new spawn (the previous spawn is stored next to the _becap postfix

## Script
* Copy the script from the xray_script / nnm_path_constructor.script folder (located in the program root) to the gamedata / scripts folder
* Registration - AS, todo
* Designer control:
   * NumPad1 - start recording the path
   * NumPad7 - add waypoint
   * NumPad9 - add point of view
   * NumPad0 - finish recording the path

## Русское описание
Программа для автоматического создания путей для X - Ray Engine 1.6.00 - 02.

Об авторах:

Леонид Кушнарёв - алгоритм генерации путей по считанным координатам

Я, [Daniil Borchev](https://github.com/daniilborschev) - алгоритм копирования и сборки спавна в соответствии с заданной локацией

## Программа
Для корректной работы программы требуется
* Для получения пути установите скрипт в игру и используйте. Описание скрипта позже
* Настроить путь до игры(в этой папке будет искаться fsgame, по которому будет находиться лог-файл)
* Настроить путь до папки со спавном
* Программа, при наличии лог - файла в указанной папке, сама загружает информацию о новых путях в окно вывода
* Для перезагрузки путей из лог - файла(например, при перезаписи этого файла) нажмите кнопку "Перезагрузить лог - файл" 
* Нажать кнопку "Копировать секции в spawn", и дождаться завершения операции копирования
* По завршению копирования программа предложит собрать новый спавн(предыдущий спавн сохраняется рядом, с постфиксом _becap

## Скрипт
* Следует копировать скрипт из папки xray_script/nnm_path_constructor.script(находится в корне программы) в папку gamedata/scripts
* Регистрация - КАК, todo
* Управление конструктором:
    * NumPad1 - начать запись пути
    * NumPad7 - добавить точку пути
    * NumPad9 - добавить точку направления взгляда
    * NumPad0 - закончить запись пути
