namespace PathConstructor
{
    partial class MainForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(MainForm));
            this.toolStrip1 = new System.Windows.Forms.ToolStrip();
            this.tsb_Linear = new System.Windows.Forms.ToolStripButton();
            this.tsb_Cycle = new System.Windows.Forms.ToolStripButton();
            this.toolStripSeparator1 = new System.Windows.Forms.ToolStripSeparator();
            this.tsb_Refresh = new System.Windows.Forms.ToolStripButton();
            this.toolStripButton1 = new System.Windows.Forms.ToolStripButton();
            this.toolStripButton2 = new System.Windows.Forms.ToolStripButton();
            this.unpack_spawn = new System.Windows.Forms.ToolStripButton();
            this.copy_section_to_spawn = new System.Windows.Forms.ToolStripButton();
            this.toolStripButton3 = new System.Windows.Forms.ToolStripButton();
            this.toolStripButton4 = new System.Windows.Forms.ToolStripButton();
            this.lbx_Paths = new System.Windows.Forms.ListBox();
            this.contextMenuListBox = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.редактироватьВыбранныйПутьToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.rtb_PathShown = new System.Windows.Forms.RichTextBox();
            this._log = new System.Windows.Forms.RichTextBox();
            this.toolTip1 = new System.Windows.Forms.ToolTip(this.components);
            this.toolStrip1.SuspendLayout();
            this.contextMenuListBox.SuspendLayout();
            this.SuspendLayout();
            // 
            // toolStrip1
            // 
            this.toolStrip1.Dock = System.Windows.Forms.DockStyle.None;
            this.toolStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.tsb_Linear,
            this.tsb_Cycle,
            this.toolStripSeparator1,
            this.tsb_Refresh,
            this.toolStripButton1,
            this.toolStripButton2,
            this.unpack_spawn,
            this.copy_section_to_spawn,
            this.toolStripButton3,
            this.toolStripButton4});
            this.toolStrip1.Location = new System.Drawing.Point(0, 0);
            this.toolStrip1.Name = "toolStrip1";
            this.toolStrip1.Size = new System.Drawing.Size(225, 25);
            this.toolStrip1.TabIndex = 1;
            this.toolStrip1.Text = "toolStrip1";
            // 
            // tsb_Linear
            // 
            this.tsb_Linear.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.tsb_Linear.Image = ((System.Drawing.Image)(resources.GetObject("tsb_Linear.Image")));
            this.tsb_Linear.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.tsb_Linear.Name = "tsb_Linear";
            this.tsb_Linear.Size = new System.Drawing.Size(23, 22);
            this.tsb_Linear.Text = "Линейный";
            this.tsb_Linear.ToolTipText = "Преобразовать путь в линейный";
            this.tsb_Linear.Click += new System.EventHandler(this.tsb_Linear_Click);
            // 
            // tsb_Cycle
            // 
            this.tsb_Cycle.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.tsb_Cycle.Image = ((System.Drawing.Image)(resources.GetObject("tsb_Cycle.Image")));
            this.tsb_Cycle.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.tsb_Cycle.Name = "tsb_Cycle";
            this.tsb_Cycle.Size = new System.Drawing.Size(23, 22);
            this.tsb_Cycle.Text = "Цикличный";
            this.tsb_Cycle.ToolTipText = "Преобразовать путь в цикличный";
            this.tsb_Cycle.Click += new System.EventHandler(this.tsb_Cycle_Click);
            // 
            // toolStripSeparator1
            // 
            this.toolStripSeparator1.Name = "toolStripSeparator1";
            this.toolStripSeparator1.Size = new System.Drawing.Size(6, 25);
            // 
            // tsb_Refresh
            // 
            this.tsb_Refresh.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.tsb_Refresh.Image = ((System.Drawing.Image)(resources.GetObject("tsb_Refresh.Image")));
            this.tsb_Refresh.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.tsb_Refresh.Name = "tsb_Refresh";
            this.tsb_Refresh.Size = new System.Drawing.Size(23, 22);
            this.tsb_Refresh.Text = "Перезагрузить лог - файл";
            this.tsb_Refresh.Click += new System.EventHandler(this.tsb_Refresh_Click);
            // 
            // toolStripButton1
            // 
            this.toolStripButton1.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.toolStripButton1.Image = ((System.Drawing.Image)(resources.GetObject("toolStripButton1.Image")));
            this.toolStripButton1.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.toolStripButton1.Name = "toolStripButton1";
            this.toolStripButton1.Size = new System.Drawing.Size(23, 22);
            this.toolStripButton1.Text = "Выбрать путь до корневой директории игры";
            this.toolStripButton1.Click += new System.EventHandler(this.directory_game);
            // 
            // toolStripButton2
            // 
            this.toolStripButton2.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.toolStripButton2.Image = ((System.Drawing.Image)(resources.GetObject("toolStripButton2.Image")));
            this.toolStripButton2.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.toolStripButton2.Name = "toolStripButton2";
            this.toolStripButton2.Size = new System.Drawing.Size(23, 22);
            this.toolStripButton2.Text = "path_to_catalog_for_spawn";
            this.toolStripButton2.ToolTipText = "Выбрать путь до каталога со spawn\'ом игры";
            this.toolStripButton2.Click += new System.EventHandler(this.toolStripButton2_Click);
            // 
            // unpack_spawn
            // 
            this.unpack_spawn.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.unpack_spawn.Image = ((System.Drawing.Image)(resources.GetObject("unpack_spawn.Image")));
            this.unpack_spawn.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.unpack_spawn.Name = "unpack_spawn";
            this.unpack_spawn.Size = new System.Drawing.Size(23, 22);
            this.unpack_spawn.Text = "Распаковать all.spawn";
            this.unpack_spawn.Click += new System.EventHandler(this.unpack_spawn_Click);
            // 
            // copy_section_to_spawn
            // 
            this.copy_section_to_spawn.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.copy_section_to_spawn.Image = ((System.Drawing.Image)(resources.GetObject("copy_section_to_spawn.Image")));
            this.copy_section_to_spawn.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.copy_section_to_spawn.Name = "copy_section_to_spawn";
            this.copy_section_to_spawn.Size = new System.Drawing.Size(23, 22);
            this.copy_section_to_spawn.Text = "Копировать секции в spawn";
            this.copy_section_to_spawn.Click += new System.EventHandler(this.copy_section_to_spawn_Click);
            // 
            // toolStripButton3
            // 
            this.toolStripButton3.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.toolStripButton3.Image = ((System.Drawing.Image)(resources.GetObject("toolStripButton3.Image")));
            this.toolStripButton3.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.toolStripButton3.Name = "toolStripButton3";
            this.toolStripButton3.Size = new System.Drawing.Size(23, 22);
            this.toolStripButton3.Text = " Инструкция";
            this.toolStripButton3.Click += new System.EventHandler(this.toolStripButton3_Click);
            // 
            // toolStripButton4
            // 
            this.toolStripButton4.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.toolStripButton4.Image = ((System.Drawing.Image)(resources.GetObject("toolStripButton4.Image")));
            this.toolStripButton4.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.toolStripButton4.Name = "toolStripButton4";
            this.toolStripButton4.Size = new System.Drawing.Size(23, 22);
            this.toolStripButton4.Text = "Авторы";
            this.toolStripButton4.Click += new System.EventHandler(this.toolStripButton4_Click);
            // 
            // lbx_Paths
            // 
            this.lbx_Paths.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lbx_Paths.ContextMenuStrip = this.contextMenuListBox;
            this.lbx_Paths.FormattingEnabled = true;
            this.lbx_Paths.ItemHeight = 14;
            this.lbx_Paths.Location = new System.Drawing.Point(575, 39);
            this.lbx_Paths.Name = "lbx_Paths";
            this.lbx_Paths.Size = new System.Drawing.Size(210, 368);
            this.lbx_Paths.TabIndex = 2;
            this.lbx_Paths.SelectedIndexChanged += new System.EventHandler(this.lbx_Paths_SelectedIndexChanged_1);
            this.lbx_Paths.MouseDown += new System.Windows.Forms.MouseEventHandler(this.lbx_Paths_MouseDown);
            // 
            // contextMenuListBox
            // 
            this.contextMenuListBox.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.редактироватьВыбранныйПутьToolStripMenuItem});
            this.contextMenuListBox.Name = "contextMenuListBox";
            this.contextMenuListBox.Size = new System.Drawing.Size(250, 26);
            // 
            // редактироватьВыбранныйПутьToolStripMenuItem
            // 
            this.редактироватьВыбранныйПутьToolStripMenuItem.Name = "редактироватьВыбранныйПутьToolStripMenuItem";
            this.редактироватьВыбранныйПутьToolStripMenuItem.Size = new System.Drawing.Size(249, 22);
            this.редактироватьВыбранныйПутьToolStripMenuItem.Text = "Редактировать выбранный путь";
            this.редактироватьВыбранныйПутьToolStripMenuItem.Click += new System.EventHandler(this.редактироватьВыбранныйПутьToolStripMenuItem_Click);
            // 
            // rtb_PathShown
            // 
            this.rtb_PathShown.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.rtb_PathShown.BackColor = System.Drawing.SystemColors.Menu;
            this.rtb_PathShown.Location = new System.Drawing.Point(12, 39);
            this.rtb_PathShown.Name = "rtb_PathShown";
            this.rtb_PathShown.ReadOnly = true;
            this.rtb_PathShown.Size = new System.Drawing.Size(557, 368);
            this.rtb_PathShown.TabIndex = 3;
            this.rtb_PathShown.Text = "";
            // 
            // _log
            // 
            this._log.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this._log.BackColor = System.Drawing.SystemColors.Menu;
            this._log.Location = new System.Drawing.Point(12, 414);
            this._log.Name = "_log";
            this._log.ReadOnly = true;
            this._log.Size = new System.Drawing.Size(773, 89);
            this._log.TabIndex = 4;
            this._log.Text = "";
            this.toolTip1.SetToolTip(this._log, "Для подробного просмотра лога кликните два раза по данному окошку");
            this._log.MouseDoubleClick += new System.Windows.Forms.MouseEventHandler(this._log_MouseDoubleClick);
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 14F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(788, 515);
            this.Controls.Add(this._log);
            this.Controls.Add(this.lbx_Paths);
            this.Controls.Add(this.rtb_PathShown);
            this.Controls.Add(this.toolStrip1);
            this.Font = new System.Drawing.Font("Courier New", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MinimumSize = new System.Drawing.Size(800, 500);
            this.Name = "MainForm";
            this.Text = "Path Constructor";
            this.Load += new System.EventHandler(this.MainForm_Load);
            this.toolStrip1.ResumeLayout(false);
            this.toolStrip1.PerformLayout();
            this.contextMenuListBox.ResumeLayout(false);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.ToolStrip toolStrip1;
        private System.Windows.Forms.ToolStripButton tsb_Linear;
        private System.Windows.Forms.ToolStripButton tsb_Cycle;
        private System.Windows.Forms.ToolStripButton tsb_Refresh;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator1;
        private System.Windows.Forms.ToolStripButton toolStripButton1;
        private System.Windows.Forms.ListBox lbx_Paths;
        private System.Windows.Forms.RichTextBox rtb_PathShown;
        private System.Windows.Forms.RichTextBox _log;
        private System.Windows.Forms.ToolStripButton toolStripButton2;
        private System.Windows.Forms.ToolStripButton toolStripButton3;
        private System.Windows.Forms.ToolStripButton copy_section_to_spawn;
        private System.Windows.Forms.ToolTip toolTip1;
        private System.Windows.Forms.ToolStripButton toolStripButton4;
        private System.Windows.Forms.ToolStripButton unpack_spawn;
        private System.Windows.Forms.ContextMenuStrip contextMenuListBox;
        private System.Windows.Forms.ToolStripMenuItem редактироватьВыбранныйПутьToolStripMenuItem;
    }
}

