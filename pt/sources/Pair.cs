using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace pt.sources
{
    public class Pair<KeyNotFoundException, ValueType>
    {
        private KeyNotFoundException _key;
        private ValueType _value;
        public Pair(KeyNotFoundException k, ValueType v)
        {
            this._key = k;
            this._value = v;
        }
        public KeyNotFoundException Key
        {
            get { return this._key; }
            set { this._key = value; }
        }
        public ValueType Value
        {
            get { return this._value; }
            set { this._value = value; }
        }

    }
}
