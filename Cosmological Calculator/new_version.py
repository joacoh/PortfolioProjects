#%%
import numpy as np
import astropy.cosmology as ac

def mpc_to_gly(dist):
    return dist*0.0032637977445371

tab = '    '

curvs = ['Flat', 'Open', 'General']
cosmo_names = ['Planck18', 'WMAP1', 'WMAP3', 'WMAP5', 'WMAP7', 'WMAP9', 'Planck13', 'Planck15']
cosmo_models = [ac.Planck18, ac.WMAP1, ac.WMAP3, ac.WMAP5, ac.WMAP7, ac.WMAP9, ac.Planck13, ac.Planck15]
cosmo_dict = {}
for key in cosmo_names:
    for value in cosmo_models:
        cosmo_dict[key] = value
        cosmo_models.remove(value)
        break

base_model = int(input('Select a base model from the following:\nPlanck18 [0]\nWMAP1 (1)\nWMAP3 (2)\nWMAP5 (3)\nWMAP7 (4)\nWMAP9 (5)\nPlanck13 (6)\nPlanck15 (7)\nEnter the digit of the model: ') or 0)
cosmo = cosmo_dict[cosmo_names[base_model]]

curv_id = int(input('Flat [0], Open (1) or General (2)?: ') or 0)
curv = curvs[curv_id]

if curv=='Open':
    cosmo = ac.LambdaCDM(cosmo.H0.value, cosmo.Om0, 0)
elif curv=='General':
    omega_vac = float(input('Enter your value of Omega_Vac: '))
    cosmo = ac.LambdaCDM(cosmo.H0.value, cosmo.Om0, omega_vac)

z = float(input('Enter redshift (z) value: ') or 3)

age_now = cosmo.age(0).value
str1 = tab+'- It is now {:.4f} Gyr since the Big Bang'.format(age_now)

age_at_z = cosmo.age(z).value
str2 = tab+'- The age at redshift z was {:.4f} Gyr'.format(age_at_z)

ligh_travel_time = cosmo.lookback_time(z).value
str3 = tab+'- The light travel time was {:.4f} Gyr'.format(ligh_travel_time)

como_dist_mpc = cosmo.comoving_distance(z).value
como_dist_gly = mpc_to_gly(como_dist_mpc)
str4 = tab+"- The comoving radial distance, which goes into Hubble's law, is {:.4f} Mpc or {:.4f} Gly".format(como_dist_mpc, como_dist_gly)

como_volume = cosmo.comoving_volume(z).value*(0.001**3)
str5 = tab+'- The comoving volume within redshift z is {:.4f} Gpc^3'.format(como_volume)

angular_diameter_mpc = cosmo.angular_diameter_distance(z).value
angular_diameter_gly = mpc_to_gly(angular_diameter_mpc)
str6 = tab+'- The angular size distance D_A is {:.4f} Mpc or {:.4f} Gly'.format(angular_diameter_mpc, angular_diameter_gly)

angular_scale = cosmo.kpc_proper_per_arcmin(z).value/60
str7 = tab+'- This gives a scale of {:.4f} kpc/"'.format(angular_scale)

lum_dist_mpc = cosmo.luminosity_distance(z).value
lum_dist_gly = mpc_to_gly(lum_dist_mpc)
str8 = tab+'- The luminosity distance D_L is {:.4f} Mpc or {:.4f} Gly'.format(lum_dist_mpc, lum_dist_gly)

mu = 5*np.log10(lum_dist_mpc*1e6)-5
str9 = tab+'- The distance modulus, m-M, is {:.4f}'.format(mu)

strings = [str1, str2, str3, str4, str5, str6, str7, str8, str9]

print('For H_0 = {}, Omega_M = {:.4f}, Omega_Vac = {:.4f} and z = {}'. format(cosmo.H0.value, cosmo.Om0, cosmo.Ode0, z))
for string in strings:
    print(string)
#%%