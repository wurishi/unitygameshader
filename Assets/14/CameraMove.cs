using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraMove : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        //graphicMat = new Material(myShader);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    //public Shader myShader;
    public Material graphicMat;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, this.graphicMat);
    }
}
