namespace pt.Forms
{
    partial class copy_sections
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
            this.progress_bar = new System.Windows.Forms.ProgressBar();
            this.info_progress = new System.Windows.Forms.Label();
            this.progress_bar_info = new System.Windows.Forms.RichTextBox();
            this.timer1 = new System.Windows.Forms.Timer(this.components);
            this.SuspendLayout();
            // 
            // progress_bar
            // 
            this.progress_bar.Location = new System.Drawing.Point(12, 35);
            this.progress_bar.Name = "progress_bar";
            this.progress_bar.Size = new System.Drawing.Size(396, 23);
            this.progress_bar.TabIndex = 0;
            // 
            // info_progress
            // 
            this.info_progress.Location = new System.Drawing.Point(12, 9);
            this.info_progress.Name = "info_progress";
            this.info_progress.Size = new System.Drawing.Size(396, 23);
            this.info_progress.TabIndex = 1;
            this.info_progress.Text = "Прогресс копирования секций...";
            // 
            // progress_bar_info
            // 
            this.progress_bar_info.BackColor = System.Drawing.SystemColors.Window;
            this.progress_bar_info.ForeColor = System.Drawing.SystemColors.InfoText;
            this.progress_bar_info.Location = new System.Drawing.Point(12, 64);
            this.progress_bar_info.Name = "progress_bar_info";
            this.progress_bar_info.ReadOnly = true;
            this.progress_bar_info.Size = new System.Drawing.Size(396, 226);
            this.progress_bar_info.TabIndex = 2;
            this.progress_bar_info.Text = "";
            // 
            // timer1
            // 
            this.timer1.Tick += new System.EventHandler(this.timer1_Tick);
            // 
            // copy_sections
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(420, 302);
            this.Controls.Add(this.progress_bar_info);
            this.Controls.Add(this.info_progress);
            this.Controls.Add(this.progress_bar);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedToolWindow;
            this.Name = "copy_sections";
            this.Text = "Копирование секций";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.copy_sections_FormClosing);
            this.Load += new System.EventHandler(this.copy_sections_Load);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.ProgressBar progress_bar;
        private System.Windows.Forms.Label info_progress;
        private System.Windows.Forms.RichTextBox progress_bar_info;
        private System.Windows.Forms.Timer timer1;
    }
}