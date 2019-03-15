# Path Constructor

## English description
Program to automatically create paths for X - Ray Engine 1.6.00 - 02.

About the authors:

Leonid Kushnaryov - algorithm for generating paths from read coordinates

I, [Daniil Borchev](https://github.com/daniilborschev) - an algorithm for copying and assembling spawn according to a given location

## Program
To work correctly, the program requires
  1) To get the path, install the script into the game and use. Script description later
  2) Configure the path to the game (this folder will be searched for fsgame, which will contain the log file)
  3) Configure the path to the spam folder
  4) The program, if there is a log file in the specified folder, loads information about new paths into the output window itself.
    4.1) To reload the paths from the log file (for example, when overwriting this file), click the "Reload log file" button
  5) Click the button "Copy sections in spawn", and wait for the copy operation to complete
  6) At the end of the copying, the program will offer to assemble a new spawn (the previous spawn is stored next to the _becap postfix

## Script
  1) Copy the script from the xray_script / nnm_path_constructor.script folder (located in the program root) to the gamedata / scripts folder
  2) Registration - AS, todo
  3) Designer control:
    3.1) NumPad1 - start recording the path
    3.2) NumPad7 - add waypoint
    3.2) NumPad9 - add point of view
    3.3) NumPad0 - finish recording the path

## Русское описание
Программа для автоматического создания путей для X - Ray Engine 1.6.00 - 02.

Об авторах:

Леонид Кушнарёв - алгоритм генерации путей по считанным координатам

Я, [Daniil Borchev](https://github.com/daniilborschev) - алгоритм копирования и сборки спавна в соответствии с заданной локацией

## Программа
Для корректной работы программы требуется
  1)  Для получения пути установите скрипт в игру и используйте. Описание скрипта позже
  2)  Настроить путь до игры(в этой папке будет искаться fsgame, по которому будет находиться лог-файл)
  3)  Настроить путь до папки со спавном
  4)  Программа, при наличии лог - файла в указанной папке, сама загружает информацию о новых путях в окно вывода
    4.1)Для перезагрузки путей из лог - файла(например, при перезаписи этого файла) нажмите кнопку "Перезагрузить лог - файл" 
  5)  Нажать кнопку "Копировать секции в spawn", и дождаться завершения операции копирования
  6)  По завршению копирования программа предложит собрать новый спавн(предыдущий спавн сохраняется рядом, с постфиксом _becap

## Скрипт
  1) Следует копировать скрипт из папки xray_script/nnm_path_constructor.script(находится в корне программы) в папку gamedata/scripts
  2) Регистрация - КАК, todo
  3) Управление конструктором:
    3.1) NumPad1 - начать запись пути
    3.2) NumPad7 - добавить точку пути
    3.2) NumPad9 - добавить точку направления взгляда
    3.3) NumPad0 - закончить запись пути
