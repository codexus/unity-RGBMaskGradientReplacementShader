using UnityEngine;

namespace Codexus.Extensions
{
    public static class GradientExtensions
    {

        /// <summary>
        /// Creates new Texture2D from gradient with given width. Default with 100px
        /// </summary>
        /// <param name="gradient">gradient</param>
        /// <param name="width">texture width</param>
        /// <returns></returns>
        public static Texture2D ToTexture(this Gradient gradient, int width = 100)
        {
            Texture2D tex = new Texture2D(width, 1);

            for (int i = 0; i < width; i++)
            {
                float percent = i / (float)width;
                Color col = gradient.Evaluate(percent);

                tex.SetPixel(i, 1, col);
                tex.Apply();
            }
            return tex;
        }


        public static Texture2D[] ToTextures(this Gradient[] gradients, int width = 100)
        {
            Texture2D[] textures = new Texture2D[gradients.Length];

            for (int i = 0; i < gradients.Length; i++)
            {
                textures[i] = gradients[i].ToTexture();
            }
            return textures;
        }
    }
}
