using UnityEngine;
using Codexus.Extensions;

namespace Codexus.ColorReplacement
{
    [RequireComponent(typeof(Renderer))]
    public class RGBMaskManager : MonoBehaviour
    {
        // property name holder
        public readonly static string[] GRADIENT_NAMES = { "_GradientTex1", "_GradientTex2", "_GradientTex3" };

        #region Editor

        [Tooltip("Replacement gradient for red channel of RGB mask.  0 = Black 1 = White")]
        public Gradient redGradient;
        [Tooltip("Replacement gradient for green channel of RGB mask. 0 = Black 1 = White")]
        public Gradient greenGradient;
        [Tooltip("Replacement gradient for blue channel of RGB mask.  0 = Black 1 = White")]
        public Gradient blueGradient;

        #endregion

        #region Getters/Setters

        /// <summary>
        /// Reference to the instanced material.
        /// </summary>
        public Material material
        {
            get
            {
                if (m_material == null)
                {
                    m_material = renderer.material;
                }
                return m_material;
            }
        }
        [SerializeField] // set it in editor if needed
        private Material m_material;

        /// <summary>
        /// Reference to renderer componnet, i.e. mesh or skinnedmesh renderer
        /// </summary>
        new public Renderer renderer
        {
            get
            {
                if (m_renderer == null) m_renderer = GetComponent<Renderer>();
                return m_renderer;
            }
        }
        private Renderer m_renderer;

        #endregion

#if UNITY_EDITOR // just in case

        /// <summary>
        /// Called on every property change in editor
        /// </summary>
        void OnValidate()
        {
            Gradient[] gradients = new Gradient[3] { redGradient, greenGradient, blueGradient };
            Texture2D[] textures = gradients.ToTextures();

            SetTextureToShader(textures);
        }

#endif

        void SetTextureToShader(Texture2D[] textures)
        {
            for (int i = 0; i < textures.Length; i++)
            {
                material.SetTexture(GRADIENT_NAMES[i], textures[i]);
            }
        }

    }
}

