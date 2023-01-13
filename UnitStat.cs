using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UnitStat : MonoBehaviour
{
    public string Name;
    public Stat Health;
    public Stat Strength;
    public Stat Movement;

    private void Awake()
    {
        Debug.Log(this.Health + this.Name);
    }
}