using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Script : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        var camera = Object.FindAnyObjectByType<Camera>();
        camera.transform.position = new Vector3(0, 0, -10);
        var cube = GameObject.Find("Cube");
        cube.transform.position = new Vector3(3, 0, 0);

        this.transform.localPosition = new Vector3(3, 0, 0);

        Vector3 posWorld = transform.parent.localToWorldMatrix.MultiplyPoint(transform.localPosition);
        Debug.Log(posWorld);

        var targetPos = camera.transform.worldToLocalMatrix.MultiplyPoint(posWorld);
        Debug.Log(targetPos);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
