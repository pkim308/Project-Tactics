using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/* Stat Class:
 * Base attributes for the stats of units.
 */

[System.Serializable]
public class Stat
{
    [SerializeField]
    private int baseValue;

    public int getValue()
    {
        return baseValue;
    }
}
