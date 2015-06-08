#include <stdio.h>
#include <assert.h>

#include <libxml/xmlmemory.h>
#include <libxml/parser.h>

#define DEFAULT_XML_FILE "nagios_configure.xml"

static int parse_services(xmlDocPtr doc, xmlNodePtr cur, FILE *fp)
{
    assert(doc || cur);
    xmlChar *key;

    cur = cur->xmlChildrenNode;
    while (cur != NULL) {	
    if ((!xmlStrcmp(cur->name, (const xmlChar *)"service_name"))) {
        key = xmlNodeListGetString(doc, cur->xmlChildrenNode, 1);
        fputs(key, fp);
		fputs("\n", fp);
        xmlFree(key);
    }
    cur = cur->next;
    }
    return 0;
}
static int parse_hosts(xmlDocPtr doc, xmlNodePtr cur, FILE *fp)
{
    assert(doc || cur);
    xmlChar *key;

    cur = cur->xmlChildrenNode;
    while (cur != NULL) {
   
    if ((!xmlStrcmp(cur->name, (const xmlChar *)"host_name"))) {
        key = xmlNodeListGetString(doc, cur->xmlChildrenNode, 1);
        fputs(key, fp);
        xmlFree(key);
    }
	
    if ((!xmlStrcmp(cur->name, (const xmlChar *)"ip_address"))) {
        key = xmlNodeListGetString(doc, cur->xmlChildrenNode, 1);
		fputs("\t", fp);
        fputs(key, fp);
        xmlFree(key);
    }
    cur = cur->next;
    }
    return 0;
}

static int parse_persons(xmlDocPtr doc, xmlNodePtr cur, FILE *fp)
{
    assert(doc || cur);
    xmlChar *key;

    cur = cur->xmlChildrenNode;
    while (cur != NULL) {
   
    if ((!xmlStrcmp(cur->name, (const xmlChar *)"name"))) {
        key = xmlNodeListGetString(doc, cur->xmlChildrenNode, 1);
        fputs(key, fp);
        xmlFree(key);
    }

    if ((!xmlStrcmp(cur->name, (const xmlChar *)"email"))) {
        key = xmlNodeListGetString(doc, cur->xmlChildrenNode, 1);
		fputs("\t", fp);
        fputs(key, fp);
        xmlFree(key);
    }
	
	if ((!xmlStrcmp(cur->name, (const xmlChar *)"tel"))) {
        key = xmlNodeListGetString(doc, cur->xmlChildrenNode, 1);
		fputs("\t", fp);
        fputs(key, fp);
        xmlFree(key);
    }
	
    cur = cur->next;
    }
    return 0;
}

static int parse(const char *file_name)
{
    assert(file_name);
	xmlNodePtr hur;

    xmlDocPtr doc;   
    xmlNodePtr cur;  
    xmlChar *id;    

    doc = xmlParseFile(file_name);
    if (doc == NULL) {
		fprintf(stderr, "Failed to parse xml file:%s\n", file_name);
		goto FAILED;
    }

    cur = xmlDocGetRootElement(doc);
    if (cur == NULL) {
		fprintf(stderr, "Root is empty.\n");
		goto FAILED;
    }

    if ((xmlStrcmp(cur->name, (const xmlChar *)"configure"))) {
		fprintf(stderr, "The root is not configure.\n");
		goto FAILED;
    }

    cur = cur->xmlChildrenNode;
	FILE *fp;
    while (cur != NULL) {
		hur = cur->xmlChildrenNode;	
		if ((!xmlStrcmp(cur->name, (const xmlChar *)"hosts"))){
			fp = fopen("hosts.list", "w+");
			while (hur != NULL){
				if ((!xmlStrcmp(hur->name, (const xmlChar *)"host"))){
					parse_hosts(doc, hur, fp);
					fputs("\n",fp);
				}
				hur = hur->next;
			}			
		} else if ((!xmlStrcmp(cur->name, (const xmlChar *)"nagios_admin"))){
			fp = fopen("nagios_admin.list", "w+");
			while (hur != NULL){			
				if ((!xmlStrcmp(hur->name, (const xmlChar *)"person"))){
					parse_persons(doc, hur, fp);
					fputs("\n",fp);
				}			
				hur = hur->next;
			}	
		}else if ((!xmlStrcmp(cur->name, (const xmlChar *)"emergency_contact"))){
			fp = fopen("emergency_contacts.list", "w+");
			while (hur != NULL){			
				if ((!xmlStrcmp(hur->name, (const xmlChar *)"person"))){
					parse_persons(doc, hur, fp);
					fputs("\n",fp);
				}			
				hur = hur->next;
			}
		}else if ((!xmlStrcmp(cur->name, (const xmlChar *)"normal_contact"))){
			fp = fopen("normal_contacts.list", "w+");
			while (hur != NULL){			
				if ((!xmlStrcmp(hur->name, (const xmlChar *)"person"))){
					parse_persons(doc, hur, fp);
					fputs("\n",fp);
				}			
				hur = hur->next;
			}	
		}else if ((!xmlStrcmp(cur->name, (const xmlChar *)"emergency_service"))){
			fp = fopen("emergency_services.list", "w+");
			while (hur != NULL){			
				if ((!xmlStrcmp(hur->name, (const xmlChar *)"service"))){
					parse_services(doc, hur, fp);
					fputs("\n",fp);
				}			
				hur = hur->next;
			}	
		}else if ((!xmlStrcmp(cur->name, (const xmlChar *)"normal_service"))){
			fp = fopen("normal_services.list", "w+");
			while (hur != NULL){			
				if ((!xmlStrcmp(hur->name, (const xmlChar *)"service"))){
					parse_services(doc, hur, fp);
					fputs("\n",fp);
				}			
				hur = hur->next;
			}	
		}
				
    cur = cur->next;
    }
	
    xmlFreeDoc(doc);
    return 0;
FAILED:
    if (doc) {
    xmlFreeDoc(doc);
    }
    return -1;
}

int main(int argc, char*argv[])
{
    char *xml_file = DEFAULT_XML_FILE;

    if (argc == 2) {
    xml_file = argv[1];
    }

    if (parse(xml_file) != 0) {
    fprintf(stderr, "Failed to parse hosts\n");
    return -1;
    }

    return 0;
}