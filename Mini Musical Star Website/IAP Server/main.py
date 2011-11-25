import webapp2
from google.appengine.ext import db
from webapp2_extras import routes
import django.utils.simplejson as simplejson
import os
import cgi
from google.appengine.ext.webapp import template
import urllib
from google.appengine.api import urlfetch
import logging

class Show(db.Model):
	# product identifier can be used as the key, as key_name
	cover_image = db.BlobProperty(default=None)
	cover_image_type = db.StringProperty()
	download_url = db.StringProperty()

class Receipt(db.Model):
	device_uuid = db.StringProperty()
	receipt = db.StringProperty()
	device_build = db.StringProperty()
	verified = db.BooleanProperty()

class MainPage(webapp2.RequestHandler):
	def get(self):
		query = Show.all()


		template_values = {
			'shows': query
		}

		path = os.path.join(os.path.dirname(__file__), 'index.html')
		self.response.out.write(template.render(path, template_values))

class Shows(webapp2.RequestHandler):
	def get(self):

		# get all the Show keys
		show_keys = []
		query = Show.all(keys_only=True)

		product_identifiers = []
		for key in query:
			product_identifiers.append(key.name())

		self.response.out.write(simplejson.dumps(product_identifiers))

	def post(self):
		key_name = cgi.escape(self.request.get('key-name'))

		# check if this key already exists in the datastore
		existing_show = Show.get_by_key_name(key_name)
		if (existing_show == None):
			# create a new Show object
			new_show = Show(key_name=key_name)

			#if user provides a cover image, store that too
			cover_image = self.request.get('cover-image')
			if (cover_image):
				new_show.cover_image = cover_image

			new_show.download_url = self.request.get('download-url')
			
			# store it in the datastore
			new_show.put()

		self.redirect('/')

class DeleteShow(webapp2.RequestHandler):
	def get(self, key_name):
		# check if the show key name exists
		existing_show = Show.get_by_key_name(key_name)
		if (existing_show):
			#delete the show
			existing_show.delete()

			self.redirect('/')
		else:
			self.error(404)

class CoverImageForShow(webapp2.RequestHandler):
	def get(self, key_name):
		
		# check if the show key name exists
		existing_show = Show.get_by_key_name(key_name)
		if (existing_show and existing_show.cover_image):
			#render the cover image
			self.response.headers['Content-Type'] = 'image/png'
			self.response.out.write(existing_show.cover_image)
		else:
			self.error(404)

class DownloadShow(webapp2.RequestHandler):
	def get(self, key_name):
		
		# check if the show key name exists
		existing_show = Show.get_by_key_name(key_name)
		if (existing_show):
			self.redirect(existing_show.download_url)
		else:
			self.error(404)

class EditShow(webapp2.RequestHandler):
	def get(self, key_name):
		# check if the show key name exists
		existing_show = Show.get_by_key_name(key_name)
		if (existing_show):
			template_values = {
			'show': existing_show
			}

			path = os.path.join(os.path.dirname(__file__), 'edit.html')
			self.response.out.write(template.render(path, template_values))
		else:
			self.error(404)

	def post(self, key_name):
		# check if the show key name exists
		existing_show = Show.get_by_key_name(key_name)
		if (existing_show):
			existing_show.download_url = self.request.get('download-url')

			cover_image = self.request.get('cover-image');
			if (cover_image):
				existing_show.cover_image = cover_image
			
			existing_show.put();
			self.redirect('/')

		else:
			self.error(404)

class NewReceipt(webapp2.RequestHandler):
	def post(self):
		json_request = {'receipt-data': self.request.get('transaction-receipt')}
		form_data = simplejson.dumps(json_request)
		logging.info('POST data: ' + form_data)

		url = ''

		build_type = self.request.get('build')
		if (build_type == 'debug'):
			url = 'https://buy.itunes.apple.com/verifyReceipt'
		elif (build_type == 'release'):
			url = 'https://buy.itunes.apple.com/verifyReceipt'
		else:
			url = 'https://buy.itunes.apple.com/verifyReceipt'
		
		logging.info('Determined URL: ' + url)
		response = urlfetch.fetch(url=url,payload=form_data,method=urlfetch.POST,deadline=10)

		appstore_response = simplejson.loads(response.content)
		if (appstore_response['status'] == 0):

			#let's save the transaction record
			r = Receipt()
			r.device_uuid = self.request.get('uuid')
			r.receipt = simplejson.dumps(appstore_response['receipt'])
			r.device_build = build_type
			r.verified = True

			r.put()

			response_data = {'verified': 'true'}
			self.response.out.write(simplejson.dumps(response_data))

		else:
			response_data = {'verified': 'true'}
			self.response.out.write(simplejson.dumps(response_data))
        
app = webapp2.WSGIApplication([
	routes.DomainRoute('api.mmsmusicalstore.appspot.com', [
		
	]),

	webapp2.Route('/', handler=MainPage, name='main-page'),
	webapp2.Route('/shows', handler=Shows, name='shows'),
	webapp2.Route('/shows/<key_name>', handler=EditShow, name='edit-show'),
	webapp2.Route('/shows/<key_name>/delete', handler=DeleteShow, name='delete-show'),
	webapp2.Route('/shows/<key_name>/cover_image', handler=CoverImageForShow, name='cover-image-for-show'),
	webapp2.Route('/shows/<key_name>/download', handler=DownloadShow, name='download-show'),
	webapp2.Route('/receipts/new', handler=NewReceipt, name='new-receipt')
], debug=True)

def main():
    app.run()

if __name__ == '__main__':
    main()