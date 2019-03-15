using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace pt
{
    public partial class _log_full : Form
    {
        public _log_full()
        {
            InitializeComponent();
        }

        private void _log_full_FormClosing(object sender, FormClosingEventArgs e)
        {
            richTextBox1.Text = "";
        }
    }
}
