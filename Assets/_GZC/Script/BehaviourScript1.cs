using UnityEngine;
using System.Collections;

public class BehaviourScript1 : MonoBehaviour {

    Transform m_selfTransform;
    readonly Vector3 UP_V3 = Vector3.up;

    public float m_speed = 5F;

	void Start () {
        m_selfTransform = this.GetComponent<Transform>( );
        
	}	
	
	void Update () {
        m_selfTransform.Rotate(UP_V3, m_speed * Time.deltaTime);
	}

}
