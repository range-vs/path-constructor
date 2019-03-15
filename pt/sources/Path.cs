using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PathConstructor
{
    /// <summary>
    /// Патрульный путь.
    /// </summary>
    public class Path
    {
        /// <summary>
        /// Создаём патрульный путь.
        /// </summary>
        /// <param name="name">Имя патрульного пути</param>
        public Path(string name)
        {
            Name = name;
        }
        /// <summary>
        /// Получить/изменить имя патрульного пути.
        /// </summary>
        public string Name { get; set; }
        /// <summary>
        /// Точки walk.
        /// </summary>
        public List<Point> PointsWalk = new List<Point>();
        /// <summary>
        /// Точки look.
        /// </summary>
        public List<Point> PointsLook = new List<Point>();
        /// <summary>
        /// Получить/изменить точку walk по индексу.
        /// </summary>
        /// <param name="index">Индекс точки walk</param>
        /// <returns>Точка walk</returns>
        public Point this [int index]
        {
            get { return PointsWalk[index]; }
            set { PointsWalk.Add(value); }
        }

        /// <summary>
        /// Напечатать патульный путь.
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            StringBuilder Section = new StringBuilder();
            Section.AppendFormat("{0}{1}{2}{3}", "[", Name, "_walk]", Environment.NewLine);
            string points = "points = ";
            for (int i = 0; i < PointsWalk.Count; i++)
                points += String.Format("p{0}{1}", i, i < PointsWalk.Count - 1 ? "," : String.Empty);
            Section.AppendFormat("{0}{1}{1}",points, Environment.NewLine);
            foreach (Point point in PointsWalk)
            {
                Section.AppendFormat("p{0}:name = wp{0}{1}", point.Index < 10 ? "0" + point.Index.ToString() : point.Index.ToString(), Environment.NewLine);
                if (point.Flags.HasValue)
                    Section.AppendFormat("p{0}:flags = 0x{1}{2}", point.Index, point.Flags, Environment.NewLine);
                Section.AppendFormat("p{0}:position = {1},{2},{3}{4}", point.Index, point.X.ToString(System.Globalization.CultureInfo.InvariantCulture), point.Y.ToString(System.Globalization.CultureInfo.InvariantCulture), point.Z.ToString(System.Globalization.CultureInfo.InvariantCulture), Environment.NewLine);
                Section.AppendFormat("p{0}:game_vertex_id = {1}{2}", point.Index, point.gvID, Environment.NewLine);
                Section.AppendFormat("p{0}:level_vertex_id = {1}{2}", point.Index, point.lvID, Environment.NewLine);
                if (point.Links < PointsWalk.Count)
                    Section.AppendFormat("p{0}:links = p{1}(1){2}{3}", point.Index, point.Links, Environment.NewLine, point.Index != PointsWalk.Count - 1 ? Environment.NewLine : String.Empty);
            }
            
            if (PointsLook.Count == 0)
                return Section.ToString();

            Section.AppendFormat("{3}{0}{1}{2}{3}", "[", Name, "_look]", Environment.NewLine);
            points = "points = ";
            for (int i = 0; i < PointsLook.Count; i++)
                points += String.Format("p{0}{1}", i, i < PointsLook.Count - 1 ? "," : String.Empty);
            Section.AppendFormat("{0}{1}{1}", points, Environment.NewLine);
            foreach (Point point in PointsLook)
            {
                Section.AppendFormat("p{0}:name = wp{0}{1}", point.Index < 10 ? "0" + point.Index.ToString() : point.Index.ToString(), Environment.NewLine);
                Section.AppendFormat("p{0}:flags = 0x{1}{2}", point.Index, point.Flags, Environment.NewLine);
                Section.AppendFormat("p{0}:position = {1},{2},{3}{4}", point.Index, point.X.ToString(System.Globalization.CultureInfo.InvariantCulture), point.Y.ToString(System.Globalization.CultureInfo.InvariantCulture), point.Z.ToString(System.Globalization.CultureInfo.InvariantCulture), Environment.NewLine);
                Section.AppendFormat("p{0}:game_vertex_id = {1}{2}", point.Index, point.gvID, Environment.NewLine);
                Section.AppendFormat("p{0}:level_vertex_id = {1}{2}", point.Index, point.lvID, Environment.NewLine);
                if (point.Links < PointsLook.Count)
                    Section.AppendFormat("p{0}:links = p{1}(1){2}{2}", point.Index, point.Links, Environment.NewLine);
            }
            return Section.ToString();
        }

        //public static Path Text_to_section(string section) // конвертация текста в секцию
        //{

        //    Path new_path = new Path();


        //}
    }
}
