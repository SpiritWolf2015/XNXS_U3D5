using UnityEditor;
using UnityEngine;
using System.Collections;
using System.IO;

public class easyTools :MonoBehaviour 
{

    #region Help informations  

    private static string msg1 = "1.If you use Group tools, please select the scene objects or Hierarchy objects! \n \n",
                          msg2 = "2.If you use Render Into Cubemap tools, please read Pop-up panel! \n \n",
                          msg3 = "3.If you use Set Texs Methods/Size tools, please select the project textures! \n \n",
                          msg4 = "4.If you use Set Mats Main Color tools, please select the scene objects! \n \n",
                          msg5 = "5.If you use Set Common Shader tools, please read Pop-up panel! \n \n",
                          msg6 = "6.If you use Export AssetBundles tools, please select the prefab!";
    #endregion  

    #region Set Mats Main Color
    [MenuItem("EasyTools/Tools/Set Mats Main Color")]
    static void SetMatsMainColor( )
    {
        Object[] tempObj = Selection.gameObjects;
        

        if (tempObj == null)
        {
            EditorUtility.DisplayDialog("Warning!", "Please select the objects in the scene!", "OK");
        }
        else 
            {
                //Mats methods  
                //Material [] tempMats=FindObjectsOfType(typeof (Material)) as Material[];
                
                foreach (GameObject tempSceneObj in tempObj)
                {
                    tempSceneObj.GetComponent<Renderer>().sharedMaterial.shader = Shader.Find("Diffuse");
                    tempSceneObj.GetComponent<Renderer>().sharedMaterial.SetColor("_Color", Color.white);
                }
            }

    }
    #endregion

    #region Active/Deactive Object Collider
    [MenuItem("EasyTools/Tools/Object/Deactive Collider")]
    static void DeactiveCollider()
    {
         Object[] tempObj = Selection.gameObjects;
         if (tempObj == null)
         {
             EditorUtility.DisplayDialog("Warning!", "Please select the objects in the scene!", "OK");
         }
         else
         {
             foreach (GameObject tempSceneObj in tempObj)
             {
                 if (tempSceneObj.GetComponent<MeshCollider>())
                 {
                     tempSceneObj.GetComponent<MeshCollider>().enabled = false;
                 }
                 
                 if (tempSceneObj.GetComponent<BoxCollider>())
                 {
                    tempSceneObj.GetComponent<BoxCollider>().enabled = false;
                 }

                 if (tempSceneObj.GetComponent<SphereCollider>())
                 {
                     tempSceneObj.GetComponent<SphereCollider>().enabled = false;
                 }

                 if (tempSceneObj.GetComponent<CapsuleCollider>())
                 {
                     tempSceneObj.GetComponent<CapsuleCollider>().enabled = false;
                 }
                
             }
         }
    }

    [MenuItem("EasyTools/Tools/Object/Active Collider")]
    static void ActiveCollider()
    {
        Object[] tempObj = Selection.gameObjects;
        if (tempObj == null)
        {
            EditorUtility.DisplayDialog("Warning!", "Please select the objects in the scene!", "OK");
        }
        else
        {
            foreach (GameObject tempSceneObj in tempObj)
            {
                if (tempSceneObj.GetComponent<MeshCollider>())
                {
                    tempSceneObj.GetComponent<MeshCollider>().enabled = true;
                }

                if (tempSceneObj.GetComponent<BoxCollider>())
                {
                    tempSceneObj.GetComponent<BoxCollider>().enabled = true;
                }

                if (tempSceneObj.GetComponent<SphereCollider>())
                {
                    tempSceneObj.GetComponent<SphereCollider>().enabled = true;
                }

                if (tempSceneObj.GetComponent<CapsuleCollider>())
                {
                    tempSceneObj.GetComponent<CapsuleCollider>().enabled = true;
                }
            }
        }
    }
    #endregion

    #region Set Texture Size
    //Textures tools informations
    //Textures size   *code from unity,fingerx integrated!*
    [MenuItem("EasyTools/Tools/Set Texs Methods/Size/32")]

    static void SetTexsSize_32 ( )
    {
        SelectedChangeMaxTexsSize(32);
    }
    [MenuItem("EasyTools/Tools/Set Texs Methods/Size/64")]

    static void SetTexsSize_64( )
    {
        SelectedChangeMaxTexsSize(64);
    }
    [MenuItem("EasyTools/Tools/Set Texs Methods/Size/128")]

    static void SetTexsSize_128( )
    {
        SelectedChangeMaxTexsSize(128);
    }

    [MenuItem("EasyTools/Tools/Set Texs Methods/Size/256")]
    static void SetTexsSize_256()
    {
        SelectedChangeMaxTexsSize(256);
    }

    [MenuItem("EasyTools/Tools/Set Texs Methods/Size/512")]
    static void SetTexsSize_512( )
    {
        SelectedChangeMaxTexsSize(512);
    }
    
    [MenuItem("EasyTools/Tools/Set Texs Methods/Size/1024")]

    static void SetTexsSize_1024( )
    {
        SelectedChangeMaxTexsSize(1024);
    }
    [MenuItem("EasyTools/Tools/Set Texs Methods/Size/2048")]

    static void SetTexsSize_2048()
    {
        SelectedChangeMaxTexsSize(2048);
    }
    
    static void SelectedChangeMaxTexsSize(int size)
    {

        Object[] texs = GetSelectedTexs();
        Selection.objects = new Object[0];
        foreach (Texture2D texture in texs)
        {
            string path = AssetDatabase.GetAssetPath(texture);
            TextureImporter textureImporter = AssetImporter.GetAtPath(path) as TextureImporter;
            textureImporter.maxTextureSize = size;
            AssetDatabase.ImportAsset(path);
        }
    }
    #endregion
    
    #region Active/Deactive Texture MiniMap
    //Textures SetTexToMiniMap   *0.4beta 2012.1.5*
    //Textures tools informations
    static Object[] GetSelectedTexs()
    {
        return Selection.GetFiltered(typeof(Texture2D), SelectionMode.DeepAssets);
    }
    [MenuItem("EasyTools/Tools/Set Texs Methods/TextureMinimap/ActiveMiniMap")]
    static void ActiveMiniMap()
    {
        Object[] texs = GetSelectedTexs();
      
        if (texs == null)
        {
            EditorUtility.DisplayDialog("Warning!", "Please select the  Texture in the scene!", "OK");
        }
        else
        {
            //Mats methods  
            //Material [] tempMats=FindObjectsOfType(typeof (Material)) as Material[];

            foreach (Texture2D texture in texs)
            {
                string path = AssetDatabase.GetAssetPath(texture);
                TextureImporter textureImporter = AssetImporter.GetAtPath(path) as TextureImporter;
                textureImporter.mipmapEnabled = true;
                AssetDatabase.ImportAsset(path);
            }
        }

    }

    [MenuItem("EasyTools/Tools/Set Texs Methods/TextureMinimap/DeactiveMiniMap")]
    static void DeactiveMiniMap()
    {
        Object[] texs = GetSelectedTexs();

        if (texs == null)
        {
            EditorUtility.DisplayDialog("Warning!", "Please select the  Texture in the scene!", "OK");
        }
        else
        {
            //Mats methods  
            //Material [] tempMats=FindObjectsOfType(typeof (Material)) as Material[];

            foreach (Texture2D texture in texs)
            {
                string path = AssetDatabase.GetAssetPath(texture);
                TextureImporter textureImporter = AssetImporter.GetAtPath(path) as TextureImporter;
                textureImporter.mipmapEnabled = false;
                AssetDatabase.ImportAsset(path);
            }
        }

    }
    #endregion

    #region Set Texture To GUI Format
    //Textures tools informations
    //Textures SetTexToGUI   *0.4beta 2012.1.5*
    [MenuItem("EasyTools/Tools/Set Texs Methods/SetTex2GUI/Apply")]
    static void SetTex2GUI()
    {
        Object[] texs = GetSelectedTexs();
       
        if (texs == null)
        {
            EditorUtility.DisplayDialog("Warning!", "Please select the  Texture in the scene!", "OK");
        }
        else
        {
            //Mats methods  
            //Material [] tempMats=FindObjectsOfType(typeof (Material)) as Material[];

            foreach (Texture2D texture in texs)
            {
                string path = AssetDatabase.GetAssetPath(texture);
                TextureImporter textureImporter = AssetImporter.GetAtPath(path) as TextureImporter;
                textureImporter.textureType = TextureImporterType.GUI;
                textureImporter.npotScale = TextureImporterNPOTScale.None;
                AssetDatabase.ImportAsset(path);
            }
        }

    }
    #endregion

    #region Group/Ungroup
    //Group and ungroup v0.2beta
    //
    [MenuItem("EasyTools/Tools/Group/Group Selection %g", false, 1)]
    static void MenuInsertParent()
    {
        Transform[] transforms = Selection.GetTransforms(SelectionMode.TopLevel |
            SelectionMode.OnlyUserModifiable);

        GameObject newParent = new GameObject("_New Group");
        Transform newParentTransform = newParent.transform;

        if (transforms.Length == 1)
        {
            Transform originalParent = transforms[0].parent;
            transforms[0].parent = newParentTransform;
            if (originalParent)
                newParentTransform.parent = originalParent;
        }

        else
        {
            foreach (Transform transform in transforms)
                transform.parent = newParentTransform;
        }
    }
    
    [MenuItem("EasyTools/Tools/Group/Ungroup %q", false, 1)]
    static void MenuDelParent()
    {
        Transform [] tempObjs =Selection.GetTransforms(SelectionMode.TopLevel |
            SelectionMode.OnlyUserModifiable);

        foreach (Transform temObj in tempObjs  )
        {
            temObj.DetachChildren(); 
        }

    }
    #endregion

    #region Export AssetBundles
    //ExportAssetBundles           
    //
    [MenuItem("EasyTools/Tools/Export AssetBundles/SingleFile/Track dependencies")]
    static void ExportResource()
    {
        // Bring up save panel
        string path = EditorUtility.SaveFilePanel("Save Resource", "", "New Resource", "unity3d");
        if (path.Length != 0)
        {
            // Build the resource file from the active selection.
            Object[] selection = Selection.GetFiltered(typeof(Object), SelectionMode.DeepAssets);
            BuildPipeline.BuildAssetBundle(Selection.activeObject, selection, path, BuildAssetBundleOptions.CollectDependencies | BuildAssetBundleOptions.CompleteAssets);
            Selection.objects = selection;
        }
    }

    [MenuItem("EasyTools/Tools/Export AssetBundles/SingleFile/No dependency tracking")]
    static void ExportResourceNoTrack()
    {
        // Bring up save panel
        string path = EditorUtility.SaveFilePanel("Save Resource", "", "New Resource", "unity3d");
        if (path.Length != 0)
        {
            // Build the resource file from the active selection.
            BuildPipeline.BuildAssetBundle(Selection.activeObject, Selection.objects, path);
        }
    }
    [MenuItem("EasyTools/Tools/Export AssetBundles/MultipleFiles/1.Create(Track dependencies)")]
    static void ExportMultipleResouce() 
    {
       
        string path = AssetDatabase.GetAssetPath(Selection.activeObject);
       
        if (path.Length != 0) 
        {
            path = path.Replace("Assets/", "");
            string[] fileEntries = Directory.GetFiles(Application.dataPath + "/" + path);
            
            foreach (string fileName in fileEntries) 
            {
                string filePath = fileName.Replace(@"\", "/");
                int index = filePath.LastIndexOf("/");
                filePath = filePath.Substring(index);

                string localPath = "Assets/" + path;
                if (index > 0) 
                {
                    localPath += filePath;
                }
                Object _target = AssetDatabase.LoadMainAssetAtPath(localPath);

                if (_target != null)
                {
                    string bundlePath = "Assets/" + path + "/" + _target.name + ".unity3d";
                    BuildPipeline.BuildAssetBundle(_target, null, bundlePath, BuildAssetBundleOptions.CollectDependencies | BuildAssetBundleOptions.CompleteAssets);
                }

            }

            AssetDatabase.Refresh();
        }
       
    }
    [MenuItem("EasyTools/Tools/Export AssetBundles/MultipleFiles/2.Selected From Floder Update AssetBundles")]
    static void _UpdateAssetBundel()
    {
       AssetDatabase.CreateFolder("Assets", "_AssetBundles");
       string path = AssetDatabase.GetAssetPath(Selection.activeObject);
       
       if (path.Length != 0)
       {
           path = path.Replace("Assets/", "");
           string[] fileEntries = Directory.GetFiles(Application.dataPath + "/" + path);
           foreach (string fileName in fileEntries)
           {               
               string filePath = fileName.Replace(@"\", "/");
               int index = filePath.LastIndexOf("/");
               filePath = filePath.Substring(index);

               string localPath = "Assets/" + path;
               if (index > 0)
               {
                   localPath += filePath;
               }

               Object _target = AssetDatabase.LoadMainAssetAtPath(localPath);

               if (_target != null)
               {
                   string bundlePath = "Assets/" + path + "/" + _target.name + ".unity3d";
                   FileInfo _fileInfo = new FileInfo(filePath);
                   if (_fileInfo.Extension == ".unity3d")
                   {
                       string _requstPath = "Assets/_AssetBundles/" + _fileInfo.Name;
                       AssetDatabase.MoveAsset(localPath, _requstPath);
                   }
                   //else
                   //{
                   //    Debug.LogWarning("Selected Floder has no *.unity3d file,Please check Floder or select others Floder!");
                   //    AssetDatabase.MoveAssetToTrash("Assets/_AssetBundles");
                   //}
               }
             
           }
       }
    }

    #endregion

    /********************************************************************/
   
    #region Help
    //Help tools informations
    //
    [MenuItem("EasyTools/Help")]
    static void ShowHelpMsg()
    {
        EditorUtility.DisplayDialog("Help", msg1 + msg2 + msg3 + msg4 + msg5 + msg6+"\n\nComming soon later!", "OK");
    }
    #endregion

    #region About
    //Show about tools informations
    //
    [MenuItem("EasyTools/About EasyTools")]
    static void ShowAboutMsg()
    {
        EditorUtility.DisplayDialog("About EasyTools", "Fingerx All rights reserved ! \n" + "Version 0.6 beta!  \n" + "If you find bugs,please send mail to:fingerx@foxmail.com.Thanks!", "OK");
    }
    #endregion

    /********************************************************************/
}

