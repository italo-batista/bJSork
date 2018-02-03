# coding: utf-8
import scrapy


class LyricSpider(scrapy.Spider):
    
    name = 'lyrics'

    start_urls = ['https://genius.com/albums/Bjork/Utopia',
        'https://genius.com/albums/Bjork/Vulnicura',
        'https://genius.com/albums/Bjork/Biophilia',
        'https://genius.com/albums/Bjork/Volta',
        'https://genius.com/albums/Bjork/Medulla',
        'https://genius.com/albums/Bjork/Drawing-restraint-9',
        'https://genius.com/albums/Bjork/Vespertine',
        'https://genius.com/albums/Bjork/Selmasongs',
        'https://genius.com/albums/Bjork/Homogenic',
        'https://genius.com/albums/Bjork/Post',
        'https://genius.com/albums/Bjork/Debut',
        'https://genius.com/albums/Bjork/Bjork'
    ]

    def parse(self, response):

        for href in response.css('.chart_row-content a::attr(href)').extract():
            yield scrapy.Request(href, callback=self.parse_album)

    def parse_album(self, response):
        
        def extract_with_css(query):
            return response.css(query).extract_first().strip()

        def extract_lyrics():
            lyrics = ""
            for line in response.css('.lyrics *::text').extract():
                lyrics += line
            
            return lyrics.replace("\n", " ").encode('utf-8').strip()

        yield {
            'song': extract_with_css('.header_with_cover_art-primary_info-title::text'),
            'lyrics': extract_lyrics(),
        }