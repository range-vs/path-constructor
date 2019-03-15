using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Configuration;
using System.IO;
using System.Text.RegularExpressions;
using pt;
using System.Diagnostics;
using pt.sources;

namespace PathConstructor
{
    public partial class MainForm : Form
    {
        /// <summary>
        /// Патрульные пути.
        /// </summary>
        static public List<Path> Patrols = new List<Path>(); // костыль?
        /// <summary>
        /// Путь до папки с игрой.
        /// Не изменяем!
        /// </summary>
        string pathToGame;
        /// <summary>
        /// Путь до лог-файла;
        /// Существует в пределах сессии!
        /// </summary>
        string pathToLog;

        static public string saveFolderSpawn; // путь до папки со спавном
        bool afolder_all_availability; // наличие распакованного спавна
        bool afolder_path_to_game; // наличие пути до игры
        static public bool edit_section;

        public MainForm()
        {
            InitializeComponent();
            // Отступ текста от края RichTextBox'а.
            rtb_PathShown.SelectionIndent = 10;
            // Отлавливаем событие Drag&Drop.
            rtb_PathShown.AllowDrop = true;
            //rtb_PathShown.DragEnter += new DragEventHandler(rtb_PathShown_DragEnter);
            rtb_PathShown.DragDrop += new DragEventHandler(rtb_PathShown_DragDrop);
        }

        //void rtb_PathShown_DragEnter(object sender, DragEventArgs e)
        //{
        //    if (e.Data.GetDataPresent("FileDrop"))
        //        e.Effect = DragDropEffects.Copy;
        //}

        #region СОБЫТИЯ ГЛАВНОГО МЕНЮ
        /// <summary>
        /// Склик на кнопке формирования линейного пути.
        /// </summary>
        private void tsb_Linear_Click(object sender, EventArgs e)
        {
            if (Patrols.Count != 0)
            {
                Patrols[lbx_Paths.SelectedIndex][Patrols[lbx_Paths.SelectedIndex].PointsWalk.Count - 1].Links = Patrols[lbx_Paths.SelectedIndex].PointsWalk.Count;
                PrintPath();
            }
            else
                _log.AppendText("Лог - файл не загружен" + Environment.NewLine);
        }

        /// <summary>
        /// Клик на кнопке формирования цикличного пути.
        /// </summary>
        private void tsb_Cycle_Click(object sender, EventArgs e)
        {
            if (Patrols.Count != 0)
            {
                Patrols[lbx_Paths.SelectedIndex][Patrols[lbx_Paths.SelectedIndex].PointsWalk.Count - 1].Links = 0;
                PrintPath();
            }
            else
                _log.AppendText("Лог - файл не загружен" + Environment.NewLine);
        }

        /// <summary>
        /// Клик на кнопке обновления текущего открытого файла.
        /// </summary>
        private void tsb_Refresh_Click(object sender, EventArgs e)
        {
            lbx_Paths.Items.Clear();
            rtb_PathShown.Clear();
            LoadPatrolData(pathToLog);
        }
        #endregion

        #region ОСТАЛЬНЫЕ СОБЫТИЯ
        /// <summary>
        /// Загрузка формы.
        /// Определяем путь до папки с игрой, если папка не указана - предложим выбрать её и отыщем лог.
        /// </summary>
        private void MainForm_Load(object sender, EventArgs e)
        {
            // Попытаемся отыскать путь до папки с игрой в конфиге.
            pathToGame = ConfigurationManager.AppSettings["PathToGame"];

            // В конфиге пути нет.
            if (String.IsNullOrEmpty(pathToGame))
            {
                // Скажем об этом.
                //MessageBox.Show("Не указан путь до корневой папки игры.");
                _log.Text += "Не указан путь до корневой папки игры.\n";
                afolder_path_to_game = false;
                // Предложим выбрать путь до корневой папки.
                //SelectedGameFolder(); // вызов метода для задания пути до директории
            }
            else // if (!String.IsNullOrEmpty(pathToGame))
            {
                // Отыщем лог-файл.
                if (FindLogFile())
                {
                    afolder_path_to_game = true;
                    LoadPatrolData(pathToLog); // Загрузим пути из файла.
                    if (FindSpawnCataloge()) // ищем путь до спавна
                    {
                        this.find_spawn(saveFolderSpawn); // ищем спавн
                        if (afolder_all_availability)
                            _log.Text += "Путь до all.spawn успешно загружен.\n";
                    }
                }
            }
        }

        /// <summary>
        /// Клик на одном из пути в списке путей.
        /// </summary>
        private void lbx_Paths_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (lbx_Paths.SelectedIndex == -1) return;
            PrintPath();
        }

        /// <summary>
        /// Событие перетаскиванее (конец) файла на форму.
        /// </summary>
        void rtb_PathShown_DragDrop(object sender, DragEventArgs e)
        {
            string[] files = (string[])e.Data.GetData("FileDrop");
            if (files != null && File.Exists(files[0]))
            {
                lbx_Paths.Items.Clear();
                LoadPatrolData(files[0]);
            }
        }
        #endregion

        #region МЕТОДЫ
        /// <summary>
        /// Отобразить выбранный путь.
        /// </summary>
        private void PrintPath()
        {
            rtb_PathShown.Text = Patrols[lbx_Paths.SelectedIndex].ToString();
        }

        /// <summary>
        /// Диалог выбора корневой папки с игрой.
        /// </summary>
        private bool SelectedGameFolder()
        {
            /// RANGE
            // Окно для выбора папки.
            FolderBrowserDialog FolderGame = new FolderBrowserDialog();
            // Пока не выбрали именно папку с игрой будем предлагать диалог выбора.
            while (true) // !File.Exists(pathToGame + System.IO.Path.DirectorySeparatorChar + @"fsgame.ltx")
            {
                if (FolderGame.ShowDialog() == System.Windows.Forms.DialogResult.Cancel) // Если нажали Cansel, путь сохраняется тот же
                    return false;
                pathToGame = FolderGame.SelectedPath; // Запомним до папки с игрой.
                if (!File.Exists(pathToGame + System.IO.Path.DirectorySeparatorChar + @"fsgame.ltx")) // Выбрали не ту папку.
                    _log.AppendText("Указана не корневая папка с игрой." + Environment.NewLine);
                else
                    break; // папка выбрана успешно, завершаем цикл выбора папки
            }
            // Сохраним путь в конфиг.
            Configuration Config = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
            KeyValueConfigurationCollection confCollection = Config.AppSettings.Settings;
            confCollection["PathToGame"].Value = FolderGame.SelectedPath;
            Config.Save(ConfigurationSaveMode.Modified);
            ConfigurationManager.RefreshSection(Config.AppSettings.SectionInformation.Name);
            if (FindSpawnCataloge()) // ищем путь до спавна
            {
                this.find_spawn(saveFolderSpawn); // ищем спавн
                if (afolder_all_availability)
                    _log.Text += "Путь до all.spawn успешно загружен.\n";
            }
            return true;
        }
        /// <summary>
        /// Ищем файл лога через fsgame.ltx.
        /// Выбираться будет файл с крайней датой изменения.
        /// </summary>
        private bool FindLogFile()
        {
            // Путь до папки с сохранениями.
            string saveFolder;
            try
            {
                saveFolder = Regex.Match(File.ReadAllText(pathToGame + System.IO.Path.DirectorySeparatorChar + @"fsgame.ltx"), @"\$app_data_root\$\s*?=\s*?(true|false)\s*?\|\s*?(true|false)\s*?\|\s*?(.+)\r", RegexOptions.Compiled).Groups[3].Value.Replace("|", String.Empty) + System.IO.Path.DirectorySeparatorChar + "logs";
            }
            catch (System.IO.FileNotFoundException)
            {
                _log.AppendText("Ошибка нахождения каталога лог-файла." + Environment.NewLine);
                return false;
            }
            catch (System.IO.DirectoryNotFoundException)
            {
                _log.AppendText("Ошибка нахождения каталога лог-файла." + Environment.NewLine);
                return false;
            }

            // Минимально возможная дата.
            DateTime letterDate = DateTime.MinValue;
            // Лог файл.
            FileInfo log = null;
            // Перебирём все файлы в папке логов.
            try
            {
                foreach (FileInfo file in new DirectoryInfo(saveFolder).GetFiles())
                {
                    // Если дата больше, то запомним папку.
                    if (file.Extension == ".log" && letterDate < file.LastWriteTime)
                    {
                        letterDate = file.LastWriteTime;
                        log = file;
                    }
                }
            }
            catch (System.IO.DirectoryNotFoundException)
            {
                _log.AppendText("Ошибка нахождения каталога лог-файла." + Environment.NewLine);
                return false;
            }
            // Если лог вообще есть.
            if (log == null)
            {
                _log.AppendText("Не найден лог - файл." + Environment.NewLine);
                return false;
            }
            // Запомним путь для последующих обновлений файла.
            pathToLog = log.FullName;
            _log.AppendText("Лог - файл успешно загружен" + Environment.NewLine);
            return true;
        }

        /// <summary>
        /// Загрузить патрульные пути.
        /// </summary>
        /// <param name="fullFilePath">Полный путь до файла с данными.</param>
        private void LoadPatrolData(string fullFilePath)
        {
            // Запомним путь до файла.
            pathToLog = fullFilePath;
            // Попытаемся расспарсить файл.
            if(File.Exists(fullFilePath)) // если такой файл существует
                Patrols = Parser.ParseFile(fullFilePath);
            else
            {
                _log.AppendText("Лог - файл не загружен" + Environment.NewLine);
                return;
            }
            // Если путей не оказалось.
            if (Patrols.Count == 0)
            {
                // Напишем об этом в окне лога.
                _log.AppendText("Не найденно патрульных путей." + Environment.NewLine);
            }
            // Нашли пути.
            else
            {
                lbx_Paths.Items.Clear(); // предварительная очистка окна
                rtb_PathShown.Clear();
                // Переберём пути и занесём их в список путей.
                for (int i = 0; i < Patrols.Count; i++)
                {
                    lbx_Paths.Items.Add(Patrols[i].Name);
                    rtb_PathShown.AppendText(Patrols[i].ToString()); // отобразим каждый путь
                    int count = this.max_length(Patrols[i].ToString()); // определить длину строки
                    string separator = new string('_', count); // создадим
                    rtb_PathShown.AppendText(separator + Environment.NewLine); // и напечатаем разделитель
                }

                // Отобразим первый путь в окне.
                //rtb_PathShown.Text = Patrols[0].ToString(); // очень странно...делал Леонид
            }
        }
        private void directory_game(object sender, EventArgs e) // выбираем директорию игры по кнопке
        {
            if (SelectedGameFolder()) // вызов метода для задания пути до директории // false - нажали отмену
            {
                if (FindLogFile()) // Отыщем лог-файл.
                    LoadPatrolData(pathToLog);  // Загрузим пути из файла.
            }
        }

        private bool FindSpawnCataloge() // ищем в fsgame путь до спавна
        {
            string saveFolder;
            try
            {
                // поиск gamedata
                string path_spawn_tmp = "";
                saveFolder = File.ReadAllText(pathToGame + System.IO.Path.DirectorySeparatorChar + @"fsgame.ltx");
                int index_l = saveFolder.IndexOf("$game_data$");
                if (index_l == -1) // если вылетели за строку
                    return false;
                int index_r = saveFolder.IndexOf("\\", index_l + 1);
                if (index_r == -1)
                    return false;
                index_l = saveFolder.LastIndexOf(" ", index_r);
                if (index_l == -1)
                    return false;
                path_spawn_tmp += saveFolder.Substring(index_l + 1, index_r - index_l);
                // поиск spawn
                index_l = saveFolder.IndexOf("$game_spawn$");
                if (index_l == -1)
                    return false;
                index_r = saveFolder.IndexOf("\\", index_l + 1);
                if (index_r == -1)
                    return false;
                index_l = saveFolder.LastIndexOf(" ", index_r);
                if (index_l == -1)
                    return false;
                path_spawn_tmp += saveFolder.Substring(index_l + 1, index_r - index_l);
                // запоминаем
                saveFolderSpawn = pathToGame + "\\" + path_spawn_tmp;
                return true;
            }
            catch (System.IO.FileNotFoundException)
            {
                _log.AppendText("Ошибка поиска каталога spawn - файла в файле fsgame.ltx. Укажите путь в ручную." + Environment.NewLine);
                return false;
            }
        }

        private void _log_MouseDoubleClick(object sender, MouseEventArgs e) // открываем лог-окошко
        {
            _log_full form = new _log_full();
            form.Show();
            form.rTBox1 = _log.Text;
        }

        private void find_spawn(string path) // ищем спавн, или его распакованную версию
        {
            try
            {
                foreach (DirectoryInfo folder in new DirectoryInfo(path).GetDirectories()) // ищем папку all
                {
                    if (folder.Name == "all") // папка найдена
                    {
                        string tmp_path = path + "all";
                        // добавляем в лист нужные файлы
                        List<string> file_main = new List<string> { "all.ltx", "guids.ltx", "section2.bin", "section4.bin" }; // для ЗП
                        foreach (FileInfo file in new DirectoryInfo(tmp_path).GetFiles()) // ищем вышедобавленные в стек файлы
                        {
                            foreach (string f in file_main) // ищем файл в листе. 
                            {
                                if (f == file.Name) // Если найден - удаляем его из листа
                                {
                                    file_main.Remove(f);
                                    break;
                                }
                            }
                        }
                        // проверяем лист
                        if (file_main.Count == 0) // ЧН/ЗП
                        {
                            _log.AppendText("В текущем каталоге \n\"" + tmp_path + "\"\nобнаружена папка all, содержащая распакованный спавн для ЧН/ЗП" + Environment.NewLine);
                            //saveFolderSpawn = tmp_path;
                            afolder_all_availability = true;
                            return;
                        }
                        else if ((file_main.Count == 1) && (file_main.ElementAt(0) == "section4.bin")) // ТЧ
                        {
                            _log.AppendText("В текущем каталоге \n\"" + tmp_path + "\"\nобнаружена папка all, содержащая распакованный спавн для ТЧ" + Environment.NewLine);
                            //saveFolderSpawn = tmp_path;
                            afolder_all_availability = true;
                            return;
                        }
                        else
                            _log.AppendText("Распакованного спавна не обнаружено." + Environment.NewLine);
                    }
                }
            }
            catch(System.IO.DirectoryNotFoundException)
            {
                _log.AppendText("Указанный путь до папки с all.spawn не найден" + Environment.NewLine);
                return;
            }


            // продолжаем поиски
            foreach (FileInfo file in new DirectoryInfo(path).GetFiles()) // ищем файл all.spawn
            {
                if (file.Name == "all.spawn") // файл найден
                {
                    _log.AppendText("В каталоге \n\"" + path + "\"\nall.spawn найден." + Environment.NewLine);
                    if (MessageBox.Show("Желаете распаковать найденный all.spawn?", "Сообщение", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
                    {
                        // распаковываем
                        Process p = new Process(); // новый процесс
                        p.StartInfo.WorkingDirectory = "subprogrammes\\acdc\\"; // рабочая директория запуска батника
                                                                                // создаём батник и пишем в него команды для работы с acdc
                        FileStream _bat = File.Create("subprogrammes\\acdc\\cmd_dec.bat");
                        StreamWriter sw = new StreamWriter(_bat);
                        sw.Write("if exist \"" + path + "all\" del \"" + path + "all\" /Q " + Environment.NewLine);
                        sw.Write("universal_acdc.pl -d \"" + path + "all.spawn\" -out \"" + path + "all\" -scan \"" + pathToGame + "\\config\" -graph \"" + pathToGame + "\\gamedata\"" + Environment.NewLine);
                        sw.Write("copy guids.ltx \"" + path + "all\\guids.ltx\" " + Environment.NewLine);
                        sw.Write("pause" + Environment.NewLine);
                        sw.Close(); _bat.Close();
                        // закрываем поток вывода в файл, затем сам файл
                        p.StartInfo.FileName = "cmd_dec.bat";
                        p.Start(); // запускаем

                        while (p.Responding)
                            this.Visible = false;
                        this.Visible = true;

                        _log.AppendText("all.spawn успешно распакован" + Environment.NewLine);
                        afolder_all_availability = true;
                        return;
                    }
                    else
                    {
                        _log.AppendText("Отказ от распаковки all.spawn'a." + Environment.NewLine);
                        return;
                    }
                }
            }
            _log.Text += "all.spawn в текущем каталоге не обнаружен.\n";

        }

        private void toolStripButton2_Click(object sender, EventArgs e) // задаём путь до спавна, и ищем там спавн
        {
            FolderBrowserDialog FolderGame = new FolderBrowserDialog();
            // Пока не выбрали именно папку со спавном будем предлагать диалог выбора.
            while (true)
            {
                if (FolderGame.ShowDialog() == System.Windows.Forms.DialogResult.Cancel) // Если нажали Cansel, путь сохраняется тот же
                    return;
                saveFolderSpawn = FolderGame.SelectedPath; // Запомним путь до папки со спавном.
                if ((pathToGame + "\\gamedata\\spawns") != saveFolderSpawn) // Выбрали не ту папку.
                {
                    _log.AppendText("Указана папка, не содержащая спавн - файлов." + Environment.NewLine);
                    return;
                }
                else
                    break; // папка выбрана успешно, завершаем цикл выбора папки
            }
            saveFolderSpawn += "\\";
            this.find_spawn(saveFolderSpawn);
        }

        private void toolStripButton3_Click(object sender, EventArgs e) // кнопка инструкция(описывается, как пользоваться программой)
        {
            MessageBox.Show("Для корректной работы программы требуется:\n" +
                "0) Для получения пути установите скрипт в игру и используйте. Описание внутри скрипта."+ 
                "1)Настроить путь до игры(в этой папке будет искаться fsgame, по которому будет находиться лог-файл);\n2)Настроить путь до папки со спавном\n" + "3)Программа, при наличии лог - файла в указанной папке, сама загружает информацию о новых путях в окно вывода;\n" + 
                "   3.1) Для перезагрузки путей из лог - файла(например, при перезаписи этого файла) нажмите кнопку \"Перезагрузить лог - файл\"\n" + 
                "4) Нажать кнопку \"Копировать секции в spawn\", и дождаться завершения операции копирования;\n" + 
                "5) По завршению копирования программа предложит собрать новый спавн(предыдущий спавн сохраняется рядом, с постфиксом _becap).", "Инструкция");
        }

        private void copy_section_to_spawn_Click(object sender, EventArgs e) // копируем секции путей в спавн
        {
            if(rtb_PathShown.Text.Length == 0)
            {
                _log.AppendText("Копировать нечего" + Environment.NewLine);
                return;
            }
            if (afolder_all_availability)
            {
                // "guids.ltx"
                List<Pair<string, int>> location = this.read_guids();
                if (location == null)
                {
                    _log.AppendText("Ни одной из определённых локаций не найдено в all.spawn'e. Копирование прекращено." + Environment.NewLine);
                    return;
                }

                // way files's
                location = this.is_file(location);
                if (location == null)
                {
                    _log.AppendText("не найдено ни одного way_ - файла локации. Копирование прекращено." + Environment.NewLine);
                    return;
                }

                // copy section's
                pt.Forms.copy_sections form;
                form = new pt.Forms.copy_sections(location);
                form.ShowDialog();

                // pack spawn
                if (MessageBox.Show("Желаете запаковать all.spawn с внесёнными изменениями?", "Сообщение", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
                {
                    if (File.Exists(saveFolderSpawn + "all.spawn"))
                    {
                        if (File.Exists(saveFolderSpawn + "all.spawn_becap")) // проверяем наличие бекапа
                            File.Delete((saveFolderSpawn + "all.spawn_becap")); // удаляем
                        File.Move(saveFolderSpawn + "all.spawn", saveFolderSpawn + "all.spawn_becap"); // переименовываем текущий спавн
                        _log.AppendText("Создан бекап прошлой версии all.spawn_becap" + Environment.NewLine);
                    }
                    Process p = new Process(); // новый процесс

                    p.StartInfo.WorkingDirectory = "subprogrammes\\acdc\\"; // рабочая директория запуска батника
                     // создаём батник и пишем в него команды для работы с acdc
                    FileStream _bat = File.Create("subprogrammes\\acdc\\cmd_com.bat");
                    StreamWriter sw = new StreamWriter(_bat);
                    sw.Write("universal_acdc.pl -compile \"" + saveFolderSpawn + "all\" -out \"" + saveFolderSpawn + "all.spawn\"" + Environment.NewLine);
                    sw.Write("pause" + Environment.NewLine);
                    sw.Close(); _bat.Close();
                    // закрываем поток вывода в файл, затем сам файл
                    p.StartInfo.FileName = "cmd_com.bat";
                    p.Start(); // запускаем

                    while (p.Responding)
                        this.Visible = false;
                    this.Visible = true;

                    _log.AppendText("all.spawn успешно запакован" + Environment.NewLine);
                    return;
                }
                else
                {
                    _log.AppendText("Отказ от запаковки all.spawn'a." + Environment.NewLine);
                    form.Close();
                    return;
                }
            }
            else
                _log.AppendText("Не удалось найти распакованный all.spawn." + Environment.NewLine);
        }

        private List<Pair<string, int>> read_guids() // считываем game-вертексы
        {
            String file = File.ReadAllText(saveFolderSpawn + "\\all\\guids.ltx"); // открываем файл, хранящий game vertex's для чтения
            List<Pair<string, int>> list = new List<Pair<string, int>>();

            // создём таблицу game_vertex's
            int index = 0;
            while (true)
            {
                if ((index = file.IndexOf('[', index + 1)) != -1)
                {
                    int index_1 = 0;
                    index_1 = file.IndexOf(']', index + 1);
                    string tmp = file.Substring(index + 1, index_1 - (index + 1));
                    index = file.IndexOf("gvid0 = ", index);
                    index_1 = file.IndexOf('\r', index);
                    string game_vertex = file.Substring(index + 8, index_1 - (index + 8));
                    list.Add(new Pair<string, int>(tmp, Convert.ToInt32(game_vertex)));
                }
                else break;
            }

            Pair<string, int>[] gvids = new Pair<string, int>[Patrols.Count];
            for (int i = 0; i < Patrols.Count; i++)
                gvids[i] = new Pair<string, int>("null", -1);

            index = 0;
            foreach (Path pt in Patrols)
            {
                if (pt.PointsLook.Count != 0)
                    gvids[index].Value = pt.PointsLook[0].gvID;
                else if (pt.PointsWalk.Count != 0)
                    gvids[index].Value = pt.PointsWalk[0].gvID;
                ++index;
            }

            foreach (Pair<string, int> pair in gvids)
            {
                if (pair.Value != -1) // если пути обнаружены
                {
                    Pair<string, int> prew = list.ElementAt(0);
                    foreach (Pair<string, int> elem in list)
                    {
                        if (pair.Value <= elem.Value)
                        {
                            pair.Key = prew.Key;
                            break;
                        }
                        prew = elem;
                    }
                }
            }
            List<Pair<string, int>> result = new List<Pair<string, int>>(gvids);
            if (result.Count != 0)
                return result;
            return null;
        }

        private List<Pair<string, int>> is_file(List<Pair<string, int>> location) // проверяем наличие файлов в каталоге ..\all
        {
            for (int i = 0; i < location.Count; i++)
            {
                if (!File.Exists(saveFolderSpawn + "\\all\\way_" + location.ElementAt(i).Key + ".ltx"))
                    location.Remove(location.ElementAt(i--)); // удаляем элемент и сразу же возвращаемся на позицию назад в листе, т.е. лист укоротился
                else
                    location.ElementAt(i).Key = "way_" + location.ElementAt(i).Key + ".ltx";
            }

            if (location.Count == 0)
                return null;
            return location;
        }

        private int max_length(string str) // опеределяет максимальную длину строки(по \r\n - новая строка)
        {
            int start = 0;
            int end = 0;
            int length = 0;
            while((end = str.IndexOf("\r\n", start)) != -1)
            {
                if (length < end - start)
                    length = end - start;
                start = end + 1;
            }
            return length;
        }

        private void lbx_Paths_SelectedIndexChanged_1(object sender, EventArgs e) // прокручивает путь до выделенного в list box
        {
            // TODO, сделать скроллинг так, чтобы найденная строка отображалась сверху
            if (this.lbx_Paths.SelectedIndex != -1)
            {
                string tmp = '[' + this.lbx_Paths.SelectedItem.ToString() + "_walk]";
                int index = this.rtb_PathShown.Text.IndexOf(tmp);
                if (index != -1)
                {
                    this.rtb_PathShown.Focus();
                    this.rtb_PathShown.SelectionStart = index;
                    rtb_PathShown.Select(index, tmp.Length);
                    return;
                }

                tmp = '[' + this.lbx_Paths.SelectedItem.ToString() + "_look]";
                index = this.rtb_PathShown.Text.IndexOf(tmp);
                if (index != -1)
                {
                    this.rtb_PathShown.Focus();
                    this.rtb_PathShown.SelectionStart = index;
                    rtb_PathShown.Select(index, tmp.Length);
                    return;
                }
            }

        }

        private void toolStripButton4_Click(object sender, EventArgs e) // об авторах
        {
            MessageBox.Show("Об авторах:\nЛеонид Кушнарёв - алгоритм генерации путей по считанным координатам;\nТрубников Иван, Даниил Борщев - алгоритм копирования и сборки спавна в соответствии с заданной локацией\n@2017 -no_mod_, Изменить бля, эту строку", "Об авторах"); 
        }

        private void unpack_spawn_Click(object sender, EventArgs e) // принудительная распаковка спавна по кнопке
        {
            if (afolder_all_availability && afolder_path_to_game)
            {
                // продолжаем поиски
                foreach (FileInfo file in new DirectoryInfo(saveFolderSpawn).GetFiles()) // ищем файл all.spawn
                {
                    if (file.Name == "all.spawn") // файл найден
                    {
                        Process p = new Process(); // новый процесс
                        p.StartInfo.WorkingDirectory = "subprogrammes\\acdc\\"; // рабочая директория запуска батника
                                                                                // создаём батник и пишем в него команды для работы с acdc
                        FileStream _bat = File.Create("subprogrammes\\acdc\\cmd_dec.bat");
                        StreamWriter sw = new StreamWriter(_bat);
                        sw.Write("if exist \"" + saveFolderSpawn + "all\" del \"" + saveFolderSpawn + "all\" /Q " + Environment.NewLine);
                        sw.Write("universal_acdc.pl -d \"" + saveFolderSpawn + "all.spawn\" -out \"" + saveFolderSpawn + "all\" -scan \"" + pathToGame + "\\config\" -graph \"" + pathToGame + "\\gamedata\"" + Environment.NewLine);
                        sw.Write("copy guids.ltx \"" + saveFolderSpawn + "all\\guids.ltx\" " + Environment.NewLine);
                        sw.Write("pause" + Environment.NewLine);
                        sw.Close(); _bat.Close();
                        // закрываем поток вывода в файл, затем сам файл
                        p.StartInfo.FileName = "cmd_dec.bat";
                        p.Start(); // запускаем

                        while (p.Responding)
                            this.Visible = false;
                        this.Visible = true;

                        _log.AppendText("all.spawn успешно распакован" + Environment.NewLine);
                        afolder_all_availability = true;
                        return;
                    }
                }
                _log.AppendText("all.spawn не найден" + Environment.NewLine);
            }
            if(!afolder_all_availability)
                _log.AppendText("all.spawn не обнаружен" + Environment.NewLine);
            if (!afolder_path_to_game)
                _log.AppendText("Не указан путь до игры" + Environment.NewLine);
        }

        private void lbx_Paths_MouseDown(object sender, MouseEventArgs e) // обрабатываем событие при нажатии ПКМ по лист боксу
        {
            // Для работы методов, надо привязать contextListBox(лежит на форме) к данному лист боксу
            if (e.Button == System.Windows.Forms.MouseButtons.Right)
            {
                if (lbx_Paths.SelectedIndex == -1)
                    contextMenuListBox.Enabled = false;
                else
                    contextMenuListBox.Enabled = true;
            }
        }

        private void редактироватьВыбранныйПутьToolStripMenuItem_Click(object sender, EventArgs e) // редактируем путь
        {
            for (int i = 0; i < Patrols.Count;i++)
            {
                if(Patrols[i].Name == lbx_Paths.SelectedItem.ToString())
                {
                    edit_section = false;
                    pt.Forms.edit_path f = new pt.Forms.edit_path(i);
                    f.ShowDialog();
                    if(edit_section)
                    {
                        rtb_PathShown.Clear();
                        lbx_Paths.Items.Clear();
                        for (int j = 0; j < Patrols.Count; j++) // перезагружаем переменную patrols в окне
                        {
                            lbx_Paths.Items.Add(Patrols[j].Name);
                            rtb_PathShown.AppendText(Patrols[j].ToString()); // отобразим каждый путь
                            int count = this.max_length(Patrols[j].ToString()); // определить длину строки
                            string separator = new string('_', count); // создадим
                            rtb_PathShown.AppendText(separator + Environment.NewLine); // и напечатаем разделитель
                        }
                        return;
                    }
                }
            }
        }

        #endregion
        
    }
}

// информация
// описание
// конструктор путей