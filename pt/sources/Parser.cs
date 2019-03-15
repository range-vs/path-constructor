using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Text.RegularExpressions;


namespace PathConstructor
{
    /// <summary>
    /// Класс-парсер данных из лог-файла.
    /// </summary>
    static class Parser
    {
        /// <summary>
        /// Парсим указанный файл на предмет наличия в нём данных о патрульных путях.
        /// </summary>
        /// <param name="fileName">Полный путь к лог-файлу</param>
        /// <returns>Список патрульных путей</returns>
        public static List<Path> ParseFile(string fileName)
        {
            // Собственно сам список с путями.
            List<Path> Paths = new List<Path>();
            // Выбранные патрульные пути.
            Regex Rg = new Regex(@"\<\[PathConstructor (\w+)\:([\s\S]+?)PathConstructor\]\>", RegexOptions.Compiled);
            // Разберём их на walk и look.
            foreach (Match match in Rg.Matches(File.ReadAllText(fileName)))
            {
                // Имя патрульного пути.
                string pathName = match.Groups[1].Value;
                // Ещё не распарсенные данные.
                string notParsePoints = match.Groups[2].Value;
                // Создадим патрульный путь.
                Path Patrol = new Path(pathName);
                // Выбирем все точки walk.
                Regex RgWalk = new Regex(@"walk:(?<index>\d\d?):(?<x>-?\d+\.?\d*),(?<y>-?\d+\.?\d*),(?<z>-?\d+\.?\d*):(?<gv>\d+):(?<lv>-?\d+)(:(?<flags>\d+))?", RegexOptions.Compiled);
                foreach (Match matchWalk in RgWalk.Matches(notParsePoints))
                {
                    // Добавим все выбранные точки walk.
                    Patrol.PointsWalk.Add(new Point(
                        Int32.Parse(matchWalk.Groups["index"].Value),
                        Double.Parse(matchWalk.Groups["x"].Value, System.Globalization.CultureInfo.InvariantCulture),
                        Double.Parse(matchWalk.Groups["y"].Value, System.Globalization.CultureInfo.InvariantCulture),
                        Double.Parse(matchWalk.Groups["z"].Value, System.Globalization.CultureInfo.InvariantCulture),
                        Int32.Parse(matchWalk.Groups["gv"].Value),
                        Int32.Parse(matchWalk.Groups["lv"].Value),
                        String.IsNullOrEmpty(matchWalk.Groups["flags"].Value) ? new int?() : Int32.Parse(matchWalk.Groups["flags"].Value)
                    ));
                }
                // Выбирем все точки look.
                Regex RgLook = new Regex(@"look:(?<index>\d\d?):(?<x>-?\d+\.?\d*),(?<y>-?\d+\.?\d*),(?<z>-?\d+\.?\d*):(?<gv>\d+):(?<lv>-?\d+):(?<flags>\d+)", RegexOptions.Compiled);
                foreach (Match matchLook in RgLook.Matches(notParsePoints))
                {
                    // Добавим все выбранные точки look.
                    Patrol.PointsLook.Add(new Point(
                        Int32.Parse(matchLook.Groups["index"].Value),
                        Double.Parse(matchLook.Groups["x"].Value, System.Globalization.CultureInfo.InvariantCulture),
                        Double.Parse(matchLook.Groups["y"].Value, System.Globalization.CultureInfo.InvariantCulture),
                        Double.Parse(matchLook.Groups["z"].Value, System.Globalization.CultureInfo.InvariantCulture),
                        Int32.Parse(matchLook.Groups["gv"].Value),
                        Int32.Parse(matchLook.Groups["lv"].Value),
                        Int32.Parse(matchLook.Groups["flags"].Value)
                    ));
                }
                // Добавим весь путь в список путей.
                Paths.Add(Patrol);
            }
            // Вернём список.
            return Paths;
        }

    }  
}
