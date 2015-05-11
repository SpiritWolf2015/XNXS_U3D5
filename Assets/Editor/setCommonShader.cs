//Set Common Shader,vesion 0.2beta!
//2011.9.15

using UnityEngine;
using UnityEditor;
using System;
using System.Collections;

public class setCommonShader : ScriptableWizard 
{
    public GameObject targetObject;
    public GameObject[] copMatObjects;

    [MenuItem("EasyTools/Tools/Set Common Shader")]

    static void appyCommonShader( )
    {
        ScriptableWizard.DisplayWizard("Set Common Shader", typeof(setCommonShader), "OK!");
    }

   
    void OnWizardUpdate( )
    {
        helpString = "First select the target object, and then select copy material objects, and finally click the OK button!";
    }
   
    void OnWizardCreate( )
    {
       foreach (GameObject tempObj in copMatObjects )
       {
           if (targetObject.GetComponent<Renderer>().sharedMaterial == null || tempObj.GetComponent<Renderer>().sharedMaterial == null)
           {
               return;
           }
               else 
               {
                   tempObj.GetComponent<Renderer>().sharedMaterial = targetObject.GetComponent<Renderer>().sharedMaterial;
               }
                    
       }
    }

}
