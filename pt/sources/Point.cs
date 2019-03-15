using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PathConstructor
{
    /// <summary>
    /// Точка патрульного пути.
    /// </summary>
    public class Point
    {
        /// <summary>
        /// Получить/изменить индекс точки.
        /// </summary>
        public int Index { get; set; }
        /// <summary>
        /// Получить флаг синхронизации walk-look.
        /// </summary>
        public int? Flags { get; set; }
        /// <summary>
        /// Получить координату X.
        /// </summary>
        public double X { get;  set; }
        /// <summary>
        /// Получить координату Y.
        /// </summary>
        public double Y { get;  set; }
        /// <summary>
        /// Получить координату Z.
        /// </summary>
        public double Z { get;  set; }
        /// <summary>
        /// Получить гейм-вертекс точки.
        /// </summary>
        public int gvID { get;  set; }
        /// <summary>
        /// Получить левел-вертекс точки.
        /// </summary>
        public int lvID { get;  set; }
        /// <summary>
        /// Получить/установить следующую точку.
        /// </summary>
        public int Links { get; set; }
        /// <summary>
        /// Создать точку патрульного пути.
        /// </summary>
        /// <param name="index">Индекс</param>
        /// <param name="x">Координата X</param>
        /// <param name="y">Координата Y</param>
        /// <param name="z">Координата Z</param>
        /// <param name="gv">Гейм-вертекс</param>
        /// <param name="lv">Левел-вертекс</param>
        /// <param name="flags">Флаг синхронизации</param>
        public Point(int index, double x, double y, double z, int gv, int lv, int? flags)
        {
            Index = index;
            Flags = flags;
            X = x;
            Y = y;
            Z = z;
            gvID = gv;
            lvID = lv;
            Links = index + 1;
        }
        public Point()
        {
            Index = -1;
            Flags = -1;
            X = Y = Z = 0;
            gvID = lvID = -1;
            Links = -1;
        }
    }
}
