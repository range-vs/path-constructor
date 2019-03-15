using PathConstructor;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace pt.Forms
{
    public partial class edit_path : Form
    {
        private int index;
        private Label[] _walk;
        private RichTextBox[] _edit_walk;
        private Label[][] _key;
        private Label[] del;
        private RichTextBox[][] _value;
        private Panel panel1;
        private Label info;
        private Label walk;
        private RichTextBox name;
        private int all_count;
        private Path tmp;
        private int color;

        public edit_path(int i) // конструктор по - умолчанию
        {
            index = i;
            this.Copy_section(); // метод для коирования значений в переменную tmp
            InitializeComponent();
            GenerateComponent(); // генерируем свои компоненты
            LoadWalk(); // по - умолчанию грузим walk
            this._left.Enabled = false;

            // Круглые кнопки
            GraphicsPath Path = new GraphicsPath();
            Path.AddEllipse(0, 0, _right.Width, _right.Height);
            Region Region = new Region(Path);
            _right.Region = Region;
            _left.Region = Region;
        }
        
        private void Copy_section() // копирование секции во временную переменную
        {
            tmp = new Path(MainForm.Patrols[index].Name);
            // копирование секции 
            tmp.PointsWalk = new List<PathConstructor.Point>();
            tmp.PointsLook = new List<PathConstructor.Point>(); 
            for (int ind = 0; ind < MainForm.Patrols[index].PointsWalk.Count; ind++) // walk
            {
                tmp.PointsWalk.Add(new PathConstructor.Point());
                tmp.PointsWalk[ind].Flags = MainForm.Patrols[index].PointsWalk[ind].Flags;
                tmp.PointsWalk[ind].Index = MainForm.Patrols[index].PointsWalk[ind].Index;
                tmp.PointsWalk[ind].Links = MainForm.Patrols[index].PointsWalk[ind].Links;
                tmp.PointsWalk[ind].X = MainForm.Patrols[index].PointsWalk[ind].X;
                tmp.PointsWalk[ind].Y = MainForm.Patrols[index].PointsWalk[ind].Y;
                tmp.PointsWalk[ind].Z= MainForm.Patrols[index].PointsWalk[ind].Z;
                tmp.PointsWalk[ind].gvID = MainForm.Patrols[index].PointsWalk[ind].gvID;
                tmp.PointsWalk[ind].lvID = MainForm.Patrols[index].PointsWalk[ind].lvID;
            }
            for (int ind = 0; ind < MainForm.Patrols[index].PointsLook.Count; ind++) // look
            {
                tmp.PointsLook.Add(new PathConstructor.Point());
                tmp.PointsLook[ind].Flags = MainForm.Patrols[index].PointsLook[ind].Flags;
                tmp.PointsLook[ind].Index = MainForm.Patrols[index].PointsLook[ind].Index;
                tmp.PointsLook[ind].Links = MainForm.Patrols[index].PointsLook[ind].Links;
                tmp.PointsLook[ind].X = MainForm.Patrols[index].PointsLook[ind].X;
                tmp.PointsLook[ind].Y = MainForm.Patrols[index].PointsLook[ind].Y;
                tmp.PointsLook[ind].Z = MainForm.Patrols[index].PointsLook[ind].Z;
                tmp.PointsLook[ind].gvID = MainForm.Patrols[index].PointsLook[ind].gvID;
                tmp.PointsLook[ind].lvID = MainForm.Patrols[index].PointsLook[ind].lvID;
            }
        }
        private bool save_all_patrols() // метод сохранения всех данных
        {
            this.resave(); // сначала сохранить все во временную переменную
            int count = 0; // количество внесенных изменений!
            if (tmp.Name != MainForm.Patrols[index].Name) // имя пути общее
            {
                MainForm.Patrols[index].Name = tmp.Name;
                ++count;
            }
            // пересохранение 
            for (int ind = 0; ind < MainForm.Patrols[index].PointsWalk.Count; ind++)
            {
                if (MainForm.Patrols[index].PointsWalk[ind].Flags != tmp.PointsWalk[ind].Flags)
                {
                    MainForm.Patrols[index].PointsWalk[ind].Flags = tmp.PointsWalk[ind].Flags;
                    ++count;
                }
                if (MainForm.Patrols[index].PointsWalk[ind].Index != tmp.PointsWalk[ind].Index)
                {
                    MainForm.Patrols[index].PointsWalk[ind].Index = tmp.PointsWalk[ind].Index;
                    ++count;
                }
                if (MainForm.Patrols[index].PointsWalk[ind].Links != tmp.PointsWalk[ind].Links)
                {
                    MainForm.Patrols[index].PointsWalk[ind].Links = tmp.PointsWalk[ind].Links;
                    ++count;
                }
                if (MainForm.Patrols[index].PointsWalk[ind].X != tmp.PointsWalk[ind].X)
                {
                    MainForm.Patrols[index].PointsWalk[ind].X = tmp.PointsWalk[ind].X;
                    ++count;
                }
                if (MainForm.Patrols[index].PointsWalk[ind].Y != tmp.PointsWalk[ind].Y)
                {
                    MainForm.Patrols[index].PointsWalk[ind].Y = tmp.PointsWalk[ind].Y;
                    ++count;
                }
                if (MainForm.Patrols[index].PointsWalk[ind].Z != tmp.PointsWalk[ind].Z)
                {
                    MainForm.Patrols[index].PointsWalk[ind].Z = tmp.PointsWalk[ind].Z;
                    ++count;
                }
                if (MainForm.Patrols[index].PointsWalk[ind].gvID != tmp.PointsWalk[ind].gvID)
                {
                    MainForm.Patrols[index].PointsWalk[ind].gvID = tmp.PointsWalk[ind].gvID;
                    ++count;
                }
                if (MainForm.Patrols[index].PointsWalk[ind].lvID != tmp.PointsWalk[ind].lvID)
                {
                    MainForm.Patrols[index].PointsWalk[ind].lvID = tmp.PointsWalk[ind].lvID;
                    ++count;
                }
            }
            for (int ind = 0; ind < MainForm.Patrols[index].PointsLook.Count; ind++)
            {
                if (MainForm.Patrols[index].PointsLook[ind].Flags != tmp.PointsLook[ind].Flags)
                {
                    MainForm.Patrols[index].PointsLook[ind].Flags = tmp.PointsLook[ind].Flags;
                    ++count;
                }
                if (MainForm.Patrols[index].PointsLook[ind].Index != tmp.PointsLook[ind].Index)
                {
                    MainForm.Patrols[index].PointsLook[ind].Index = tmp.PointsLook[ind].Index;
                    ++count;
                }
                if (MainForm.Patrols[index].PointsLook[ind].Links != tmp.PointsLook[ind].Links)
                {
                    MainForm.Patrols[index].PointsLook[ind].Links = tmp.PointsLook[ind].Links;
                    ++count;
                }
                if (MainForm.Patrols[index].PointsLook[ind].X != tmp.PointsLook[ind].X)
                {
                    MainForm.Patrols[index].PointsLook[ind].X = tmp.PointsLook[ind].X;
                    ++count;
                }
                if (MainForm.Patrols[index].PointsLook[ind].Y != tmp.PointsLook[ind].Y)
                {
                    MainForm.Patrols[index].PointsLook[ind].Y = tmp.PointsLook[ind].Y;
                    ++count;
                }
                if (MainForm.Patrols[index].PointsLook[ind].Z != tmp.PointsLook[ind].Z)
                {
                    MainForm.Patrols[index].PointsLook[ind].Z = tmp.PointsLook[ind].Z;
                    ++count;
                }
                if (MainForm.Patrols[index].PointsLook[ind].gvID != tmp.PointsLook[ind].gvID)
                {
                    MainForm.Patrols[index].PointsLook[ind].gvID = tmp.PointsLook[ind].gvID;
                    ++count;
                }
                if (MainForm.Patrols[index].PointsLook[ind].lvID != tmp.PointsLook[ind].lvID)
                {
                    MainForm.Patrols[index].PointsLook[ind].lvID = tmp.PointsLook[ind].lvID;
                    ++count;
                }
            }
            if(count == 0)
                return false;
            MainForm.edit_section = true;
            return true;
        }

        private void save_Click(object sender, EventArgs e) // кнопка сохранить
        {
            if (save_all_patrols())
                _save.Text = "Сохранено";
            else
                _save.Text = "Нечего сохранять";
            timer1.Start();
            color = 0;
        }

        private void edit_path_FormClosing(object sender, FormClosingEventArgs e)  // при закрытии 
        {
            if (compare()) // если имеются несохранённые данные
            {
                // выводим табличку о том, сохранить ли?
                if (MessageBox.Show("Желаете сохранить изменения?", "Предупреждение", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
                    save_all_patrols();
            }
            this.RemoveAll(); // очищаем все созданные в ручную компоненты
        }

        private void _right_Click(object sender, EventArgs e)
        {
            this.HideAll();
            this.LoadLook();
            this._right.Enabled = false;
            this._left.Enabled = true;
        }

        private void _left_Click(object sender, EventArgs e)
        {
            this.HideAll();
            this.LoadWalk();
            this._right.Enabled = true;
            this._left.Enabled = false;
        }

        private void GenerateComponent()
        {
            // создаем label и rich text box
            info = new Label();
            info.Size = new System.Drawing.Size(440, 22);
            info.Location = new System.Drawing.Point(8, 11);
            // info.Text = "walk";
            info.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            walk = new Label();
            walk.Size = new System.Drawing.Size(152, 33);
            walk.Location = new System.Drawing.Point(5, 43);
            //walk.Text = "walk_name: ";
            walk.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            name = new RichTextBox();
            name.Size = new System.Drawing.Size(200, 32);
            name.Location = new System.Drawing.Point(165, 43);
            name.Text = tmp.Name;

            // создаем панель
            panel1 = new Panel();
            panel1.AutoScroll = true;
            panel1.Size = new System.Drawing.Size(492, 400);
            panel1.Location = new System.Drawing.Point(16, 15);
            panel1.Hide();
            panel1.Controls.Add(name);
            panel1.Controls.Add(walk);
            panel1.Controls.Add(info);

            // создаём нужное количество компонент
            int _y = 87;
            int path_walk_count = tmp.PointsWalk.Count;
            int path_look_count = tmp.PointsLook.Count;
            all_count = path_look_count > path_walk_count ? path_look_count : path_walk_count;
            _edit_walk = new RichTextBox[all_count];
            _walk = new System.Windows.Forms.Label[path_look_count > path_walk_count ? path_look_count : path_walk_count];
            _key = new Label[_walk.Length][];
            _value = new RichTextBox[_walk.Length][];
            del = new Label[_walk.Length];
            _y = 110; // 86
            for (int j = 0; j < _walk.Length; j++)
            {
                del[j] = new Label();
                del[j].Location = new System.Drawing.Point(30, _y - 30);
                del[j].Size = new System.Drawing.Size(420, 20);
                del[j].TextAlign = System.Drawing.ContentAlignment.TopLeft;
                del[j].Hide();
                _y += (52 * 9) + 24;
                for (int k = 0; k < 100; k++)
                    del[j].Text += "_";
                _key[j] = new Label[8];
                _value[j] = new RichTextBox[8];
            }
            _y = 110; // 86
            for (int ind = 0; ind < _walk.Length; ind++) // сначала массив walk
            {        
                _walk[ind] = new Label();
                _walk[ind].Location = new System.Drawing.Point(50, _y);
                _walk[ind].Size = new System.Drawing.Size(70, 33);
                _walk[ind].TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
                _edit_walk[ind] = new RichTextBox();
                _edit_walk[ind].Location = new System.Drawing.Point(120, _y);
                _edit_walk[ind].Size = new System.Drawing.Size(250, 33);
                _edit_walk[ind].Enabled = false; // т.к. в классе Path нет хранения имени
                //
                _y += 52;
                for (int j = 0; j < 8; j++)
                {
                    _key[ind][j] = new Label();
                    _key[ind][j].Location = new System.Drawing.Point(10, _y);
                    _key[ind][j].Size = new System.Drawing.Size(100, 33);
                    _key[ind][j].TextAlign = System.Drawing.ContentAlignment.MiddleRight;
                    //
                    _value[ind][j] = new RichTextBox();
                    _value[ind][j].Location = new System.Drawing.Point(120, _y);
                    _value[ind][j].Size = new System.Drawing.Size(250, 33);
                    //
                    panel1.Controls.Add(_key[ind][j]);
                    panel1.Controls.Add(_value[ind][j]);
                    _key[ind][j].Hide();
                    _value[ind][j].Hide();
                    //
                    _y += 52;
                }
                _key[ind][0].Text = "Flags:"; // _value[0].Text = MainForm.Patrols[index].PointsWalk[ind].Flags.ToString();
                _key[ind][1].Text = "Index:"; // _value[1].Text = MainForm.Patrols[index].PointsWalk[ind].Index.ToString();
                _key[ind][2].Text = "Links:"; // _value[2].Text = MainForm.Patrols[index].PointsWalk[ind].Links.ToString();
                _key[ind][3].Text = "X:"; // _value[3].Text = MainForm.Patrols[index].PointsWalk[ind].X.ToString();
                _key[ind][4].Text = "Y:"; // _value[4].Text = MainForm.Patrols[index].PointsWalk[ind].Y.ToString();
                _key[ind][5].Text = "Z:"; // _value[5].Text = MainForm.Patrols[index].PointsWalk[ind].Z.ToString();
                _key[ind][6].Text = "Game vertex:"; // _value[6].Text = MainForm.Patrols[index].PointsWalk[ind].gvID.ToString();
                _key[ind][7].Text = "Level vertex:"; // _value[7].Text = MainForm.Patrols[index].PointsWalk[ind].lvID.ToString();
                _y += 24;
            }

            // добавим данные в панель
            for (int j = 0; j < tmp.PointsWalk.Count; j++)
            {
                panel1.Controls.Add(del[j]);
                panel1.Controls.Add(_walk[j]);
                panel1.Controls.Add(_edit_walk[j]);
            }

            this.Controls.Add(panel1);
        }

        private void LoadWalk()
        {
            // получаем количество walk-s
            // грузим из секций инфу и отображаем нужное кол-во информации
            info.Text = "walk";
            walk.Text = "path_name:";
            name.Text = tmp.Name;
            for (int ind = 0; ind < tmp.PointsWalk.Count; ind++)
            {
                  del[ind].Show();
                _walk[ind].Show();
                _edit_walk[ind].Show();
                _walk[ind].Text = "name" + ind.ToString() + ":";
                _edit_walk[ind].Text = "wp" + ((ind < 10) ? ('0' + ind.ToString()) : ind.ToString());
                for (int j = 0; j < 8; j++)
                {
                    _key[ind][j].Show();
                    _value[ind][j].Show();
                }
                _value[ind][0].Text = tmp.PointsWalk[ind].Flags.ToString();
                _value[ind][1].Text = tmp.PointsWalk[ind].Index.ToString();
                _value[ind][2].Text = tmp.PointsWalk[ind].Links.ToString();
                _value[ind][3].Text = tmp.PointsWalk[ind].X.ToString();
                _value[ind][4].Text = tmp.PointsWalk[ind].Y.ToString();
                _value[ind][5].Text = tmp.PointsWalk[ind].Z.ToString();
                _value[ind][6].Text = tmp.PointsWalk[ind].gvID.ToString();
                _value[ind][7].Text = tmp.PointsWalk[ind].lvID.ToString();
            }
            panel1.Show();
        }

        private void LoadLook()
        {
            info.Text = "look";
            walk.Text = "path_name:";
            name.Text = tmp.Name;
            panel1.Show();
            for (int ind = 0; ind < tmp.PointsLook.Count; ind++)
            {
                del[ind].Show();
                _walk[ind].Show();
                _edit_walk[ind].Show();
                _walk[ind].Text = "name" + ind.ToString() + ":";
                _edit_walk[ind].Text = "wp" + ((tmp.PointsLook[ind].Flags < 10) ? ('0' + tmp.PointsLook[ind].Flags.ToString()) : tmp.PointsLook[ind].Flags.ToString());
                for (int j = 0; j < 8; j++)
                {
                    _key[ind][j].Show();
                    _value[ind][j].Show();
                }
                _value[ind][0].Text = tmp.PointsLook[ind].Flags.ToString();
                _value[ind][1].Text = tmp.PointsLook[ind].Index.ToString();
                _value[ind][2].Text = tmp.PointsLook[ind].Links.ToString();
                _value[ind][3].Text = tmp.PointsLook[ind].X.ToString();
                _value[ind][4].Text = tmp.PointsLook[ind].Y.ToString();
                _value[ind][5].Text = tmp.PointsLook[ind].Z.ToString();
                _value[ind][6].Text = tmp.PointsLook[ind].gvID.ToString();
                _value[ind][7].Text = tmp.PointsLook[ind].lvID.ToString();
            }
        }

        private void HideAll()
        {
            this.resave();
            for (int ind = 0; ind < all_count; ind++)
            {
                _walk[ind].Hide();
                _edit_walk[ind].Hide();
                del[ind].Hide();
                for (int j = 0; j < 8; j++)
                {
                    _key[ind][j].Hide();
                    _value[ind][j].Hide();
                }
            }
        }

        private void RemoveAll()
        {
            panel1.Controls.Remove(info);
            panel1.Controls.Remove(walk);
            panel1.Controls.Remove(name);
            for (int ind = 0; ind < all_count; ind++)
            {
                panel1.Controls.Remove(_walk[ind]);
                panel1.Controls.Remove(_edit_walk[ind]);
                panel1.Controls.Remove(del[ind]);
                for (int j = 0; j < 8; j++)
                {
                    panel1.Controls.Remove(_key[ind][j]);
                    panel1.Controls.Remove(_value[ind][j]);
                }
            }
        }

        private void resave() // пересохранение всего в tmp, при переключении на другую вкладку
        {
            if (name.Text != tmp.Name) // имя пути общее
                tmp.Name = name.Text;
            if (_left.Enabled == false) // walk
            {
                for (int ind = 0; ind < MainForm.Patrols[index].PointsWalk.Count; ind++)
                {
                    if (_value[ind][0].Text != tmp.PointsWalk[ind].Flags.ToString())
                        tmp.PointsWalk[ind].Flags = Convert.ToInt32(_value[ind][0].Text);
                    if (_value[ind][1].Text != tmp.PointsWalk[ind].Index.ToString())
                        tmp.PointsWalk[ind].Index = Convert.ToInt32(_value[ind][1].Text);
                    if (_value[ind][2].Text != tmp.PointsWalk[ind].Links.ToString())
                        tmp.PointsWalk[ind].Links = Convert.ToInt32(_value[ind][2].Text);
                    if (_value[ind][3].Text != tmp.PointsWalk[ind].X.ToString())
                        tmp.PointsWalk[ind].X = Convert.ToDouble(_value[ind][3].Text);
                    if (_value[ind][4].Text != tmp.PointsWalk[ind].Y.ToString())
                        tmp.PointsWalk[ind].Y = Convert.ToDouble(_value[ind][4].Text);
                    if (_value[ind][5].Text != tmp.PointsWalk[ind].Z.ToString())
                        tmp.PointsWalk[ind].Z = Convert.ToDouble(_value[ind][5].Text);
                    if (_value[ind][6].Text != tmp.PointsWalk[ind].gvID.ToString())
                        tmp.PointsWalk[ind].gvID = Convert.ToInt32(_value[ind][6].Text);
                    if (_value[ind][7].Text != tmp.PointsWalk[ind].lvID.ToString())
                        tmp.PointsWalk[ind].lvID = Convert.ToInt32(_value[ind][7]);
                }
            }
            else
            {
                // тоже самое для look
                for (int ind = 0; ind < MainForm.Patrols[index].PointsLook.Count; ind++)
                {
                    if (_value[ind][0].Text != tmp.PointsLook[ind].Flags.ToString())
                        tmp.PointsLook[ind].Flags = Convert.ToInt32(_value[ind][0].Text);
                    if (_value[ind][1].Text != tmp.PointsLook[ind].Index.ToString())
                        tmp.PointsLook[ind].Index = Convert.ToInt32(_value[ind][1].Text);
                    if (_value[ind][2].Text != tmp.PointsLook[ind].Links.ToString())
                        tmp.PointsLook[ind].Links = Convert.ToInt32(_value[ind][2].Text);
                    if (_value[ind][3].Text != tmp.PointsLook[ind].X.ToString())
                        tmp.PointsLook[ind].X = Convert.ToDouble(_value[ind][3].Text);
                    if (_value[ind][4].Text != tmp.PointsLook[ind].Y.ToString())
                        tmp.PointsLook[ind].Y = Convert.ToDouble(_value[ind][4].Text);
                    if (_value[ind][5].Text != tmp.PointsLook[ind].Z.ToString())
                        tmp.PointsLook[ind].Z = Convert.ToDouble(_value[ind][5].Text);
                    if (_value[ind][6].Text != tmp.PointsLook[ind].gvID.ToString())
                        tmp.PointsLook[ind].gvID = Convert.ToInt32(_value[ind][6].Text);
                    if (_value[ind][7].Text != tmp.PointsLook[ind].lvID.ToString())
                        tmp.PointsLook[ind].lvID = Convert.ToInt32(_value[ind][7].Text);
                }
            }
        }

        private void timer1_Tick(object sender, EventArgs e)
        {
            if (this.color > 255)
                timer1.Stop();
            else
            {
                _save.ForeColor = Color.FromArgb(255, color, color, color);
                if (color == 255)
                    color++;
                else if (color + 8 < 255)
                    color += 8;
                else
                    color = 255;
            }
        }

        private bool compare() // сравниваем tmp и основную секцию
        {
            this.resave(); // сначала сохранить все во временную переменную
            int count = 0; // количество внесенных изменений!
            if (tmp.Name != MainForm.Patrols[index].Name) // имя пути общее
                ++count;
            // пересохранение 
            for (int ind = 0; ind < MainForm.Patrols[index].PointsWalk.Count; ind++)
            {
                if (MainForm.Patrols[index].PointsWalk[ind].Flags != tmp.PointsWalk[ind].Flags)
                    ++count;
                if (MainForm.Patrols[index].PointsWalk[ind].Index != tmp.PointsWalk[ind].Index)
                    ++count;
                if (MainForm.Patrols[index].PointsWalk[ind].Links != tmp.PointsWalk[ind].Links)
                    ++count;
                if (MainForm.Patrols[index].PointsWalk[ind].X != tmp.PointsWalk[ind].X)
                    ++count;
                if (MainForm.Patrols[index].PointsWalk[ind].Y != tmp.PointsWalk[ind].Y)
                    ++count;
                if (MainForm.Patrols[index].PointsWalk[ind].Z != tmp.PointsWalk[ind].Z)
                    ++count;
                if (MainForm.Patrols[index].PointsWalk[ind].gvID != tmp.PointsWalk[ind].gvID)
                    ++count;
                if (MainForm.Patrols[index].PointsWalk[ind].lvID != tmp.PointsWalk[ind].lvID)
                    ++count;
            }
            for (int ind = 0; ind < MainForm.Patrols[index].PointsLook.Count; ind++)
            {
                if (MainForm.Patrols[index].PointsLook[ind].Flags != tmp.PointsLook[ind].Flags)
                    ++count;
                if (MainForm.Patrols[index].PointsLook[ind].Index != tmp.PointsLook[ind].Index)
                    ++count;
                if (MainForm.Patrols[index].PointsLook[ind].Links != tmp.PointsLook[ind].Links)
                    ++count;
                if (MainForm.Patrols[index].PointsLook[ind].X != tmp.PointsLook[ind].X)
                    ++count;
                if (MainForm.Patrols[index].PointsLook[ind].Y != tmp.PointsLook[ind].Y)
                    ++count;
                if (MainForm.Patrols[index].PointsLook[ind].Z != tmp.PointsLook[ind].Z)
                    ++count;
                if (MainForm.Patrols[index].PointsLook[ind].gvID != tmp.PointsLook[ind].gvID)
                    ++count;
                if (MainForm.Patrols[index].PointsLook[ind].lvID != tmp.PointsLook[ind].lvID)
                    ++count;
            }
            if (count == 0)
                return false;
            return true;
        }
    }
}
