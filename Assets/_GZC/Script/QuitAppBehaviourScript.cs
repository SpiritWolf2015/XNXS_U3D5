using UnityEngine;
using System.Collections;

public class QuitAppBehaviourScript : MonoBehaviour {

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
		if(Input.GetKeyDown(KeyCode.Escape) || Input.GetKeyDown(KeyCode.Home)){
			Application.Quit();
		}
	}
}
