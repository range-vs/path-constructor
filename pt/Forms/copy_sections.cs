using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using PathConstructor;
using pt.sources;
using System.IO;

namespace pt.Forms
{
    public partial class copy_sections : Form
    {
        List<Pair<string, int>> ways_path;
        int index;

        public copy_sections(List<Pair<string, int>> way)
        {
            this.ways_path = way;
            InitializeComponent();
        }

        private void copy_sections_Load(object sender, EventArgs e)
        {
            this.timer1.Start();
            this.index = 0;
            this.progress_bar.Minimum = 0;
            this.progress_bar.Maximum = MainForm.Patrols.Count;
        }

        private void timer1_Tick(object sender, EventArgs e)
        {
            if (this.progress_bar.Value != this.progress_bar.Maximum)
            {
                this.progress_bar.Increment(1);
                StreamWriter sw = null;
                //if (File.Exists(MainForm.saveFolderSpawn + "all\\" + this.ways_path.ElementAt(index).Key)) // проверка была выше
                sw = File.AppendText(MainForm.saveFolderSpawn + "all\\" + this.ways_path.ElementAt(index).Key);
                sw.WriteLine(MainForm.Patrols[index].ToString());
                sw.Close();
                this.progress_bar_info.AppendText(MainForm.Patrols[index].Name  + " | " + this.ways_path.ElementAt(index++).Key + Environment.NewLine);
            }
        }

        private void copy_sections_FormClosing(object sender, FormClosingEventArgs e)
        {
            this.timer1.Stop();
        }

    }
}
