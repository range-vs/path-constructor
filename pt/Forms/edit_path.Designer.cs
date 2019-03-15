using PathConstructor;
using System.Windows.Forms;

namespace pt.Forms
{
    partial class edit_path
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
            this.save = new System.Windows.Forms.Button();
            this._right = new System.Windows.Forms.Button();
            this._left = new System.Windows.Forms.Button();
            this._save = new System.Windows.Forms.Label();
            this.timer1 = new System.Windows.Forms.Timer(this.components);
            this.SuspendLayout();
            // 
            // save
            // 
            this.save.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.save.Location = new System.Drawing.Point(693, 13);
            this.save.Margin = new System.Windows.Forms.Padding(4);
            this.save.Name = "save";
            this.save.Size = new System.Drawing.Size(123, 52);
            this.save.TabIndex = 1;
            this.save.Text = "Сохранить изменения";
            this.save.UseVisualStyleBackColor = true;
            this.save.Click += new System.EventHandler(this.save_Click);
            // 
            // _right
            // 
            this._right.BackColor = System.Drawing.SystemColors.Control;
            this._right.FlatAppearance.BorderSize = 0;
            this._right.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this._right.Image = global::pt.Properties.Resources.arrow_r;
            this._right.Location = new System.Drawing.Point(774, 448);
            this._right.Name = "_right";
            this._right.Size = new System.Drawing.Size(42, 42);
            this._right.TabIndex = 4;
            this._right.UseVisualStyleBackColor = false;
            this._right.Click += new System.EventHandler(this._right_Click);
            // 
            // _left
            // 
            this._left.BackColor = System.Drawing.SystemColors.Control;
            this._left.FlatAppearance.BorderSize = 0;
            this._left.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this._left.Image = global::pt.Properties.Resources.arrow_l;
            this._left.Location = new System.Drawing.Point(693, 448);
            this._left.Name = "_left";
            this._left.Size = new System.Drawing.Size(42, 42);
            this._left.TabIndex = 5;
            this._left.UseVisualStyleBackColor = false;
            this._left.Click += new System.EventHandler(this._left_Click);
            // 
            // _save
            // 
            this._save.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
            this._save.Location = new System.Drawing.Point(693, 69);
            this._save.Name = "_save";
            this._save.Size = new System.Drawing.Size(123, 48);
            this._save.TabIndex = 6;
            this._save.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // timer1
            // 
            this.timer1.Interval = 200;
            this.timer1.Tick += new System.EventHandler(this.timer1_Tick);
            // 
            // edit_path
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.Window;
            this.ClientSize = new System.Drawing.Size(829, 522);
            this.Controls.Add(this._save);
            this.Controls.Add(this._left);
            this.Controls.Add(this._right);
            this.Controls.Add(this.save);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.Margin = new System.Windows.Forms.Padding(4);
            this.MaximizeBox = false;
            this.Name = "edit_path";
            this.Text = "edit_path";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.edit_path_FormClosing);
            this.ResumeLayout(false);

        }


        #endregion
        private System.Windows.Forms.Button save;
        private System.Windows.Forms.Button _right;
        private System.Windows.Forms.Button _left;
        private Label _save;
        private Timer timer1;
    }
}