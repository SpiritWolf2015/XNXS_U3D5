class RenderCubemapWizard extends ScriptableWizard
{
    var renderFromPosition : Transform;
    var cubemap : Cubemap;
    
    var mySkyBoxMat : Material;
    
    function OnWizardUpdate()
    {
        helpString = "Select transform to render from and cubemap to render into";
        isValid = (renderFromPosition != null) && (cubemap != null);
    }
    
    function OnWizardCreate()
    {
        // create temporary camera for rendering
        var go = new GameObject( "CubemapCamera", Camera );
        
//        go.camera.backgroundColor = Color (0.1, 0.1, 0.1, 1.0);
        
        go.GetComponent.<Camera>().clearFlags = CameraClearFlags.Skybox;
        if (!go.GetComponent (Skybox))
        	go.AddComponent (Skybox);
        
        (go.GetComponent (Skybox) as Skybox).material = mySkyBoxMat;
        
        // place it on the object
        go.transform.position = renderFromPosition.position;
        if( renderFromPosition.GetComponent.<Renderer>() )
        	go.transform.position = renderFromPosition.GetComponent.<Renderer>().bounds.center;
        	
        go.transform.rotation = Quaternion.identity;
        
        go.GetComponent.<Camera>().fieldOfView = 90.0;
        go.GetComponent.<Camera>().aspect = 1.0;

        // render into cubemap        
        go.GetComponent.<Camera>().RenderToCubemap( cubemap );
        
        // destroy temporary camera
        DestroyImmediate( go );
    }
    
    @MenuItem("EasyTools/Tools/Render Into Cubemap", false, 4)
    static function RenderCubemap()
    {
        ScriptableWizard.DisplayWizard("Render cubemap", RenderCubemapWizard, "Render!");
    }
}
