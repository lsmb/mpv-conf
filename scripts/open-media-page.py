from imdb import IMDb
from guessit import guessit
from jikanpy import Jikan
import sys
import webbrowser
import anitopy

jikan = Jikan()


def get_imdb_url(filename):
    result = None
    ia = IMDb()
    g = guessit(filename)
    t = g['title']
    if 'year' in g:
        t = '{} {}'.format(t, g['year'])
    results = ia.search_movie(t)
    if g['type'] == 'episode':
        it = iter(res for res in results if res['kind'] == 'tv series')
        while not result:
            series = next(it)
            ia.update(series, 'episodes')
            if (g['season'] in series['episodes']) and (
                g['episode'] in series['episodes'][g['season']]
            ):
                result = series['episodes'][g['season']][g['episode']]
    else:
        result = next(
            iter(res for res in results if res['kind'] not in ['tv series', 'episode'])
        )
    return ia.get_imdbURL(result)


def get_mal_url(filename):
    title = anitopy.parse(filename)['anime_title']
    anime_id = jikan.search('anime', title)

    return anime_id['results'][0]['url']


if __name__ == '__main__':
    try:

        anime = True

        if anime:
            url = get_mal_url(sys.argv[1])
        else:
            url = get_imdb_url(sys.argv[1])

        webbrowser.register(
            'firefox-developer-edition',
            None,
            webbrowser.GenericBrowser('firefox-developer-edition'),
        )
        webbrowser.get('firefox-developer-edition').open(url)

        # For normal people webbrowser.open_new_tab(url)
    except:
        sys.stderr.write('Failed to find media URL')
        sys.exit(1)
