from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.enum.shapes import MSO_SHAPE, MSO_CONNECTOR
from pptx.enum.dml import MSO_THEME_COLOR
from pptx.enum.text import MSO_AUTO_SIZE
from pptx.enum.shapes import MSO_CONNECTOR
from pptx.oxml.xmlchemy import OxmlElement
from pptx.oxml.ns import qn
from PIL import Image
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "docs" / "presentation-output"
OUT_DIR.mkdir(parents=True, exist_ok=True)

W, H = 13.333, 7.5
BG = "09111F"
INK = "F6F4EF"
MUTED = "A8B1C2"
LINE = "27334A"
ORANGE = "F18F4E"
BLUE = "6874F4"
TEAL = "58C4B2"
RED = "E16B6A"
PALE = "EAF0F9"
FONT = "Aptos"

prs = Presentation()
prs.slide_width = Inches(W)
prs.slide_height = Inches(H)
blank = prs.slide_layouts[6]

img_title = ROOT / "terra_nt" / "assets" / "images" / "scenes" / "full_nt.jpg"
img_saved = ROOT / "docs" / "presentation-output" / "terra-nt-simulator-app-capture.png"
img_detail = ROOT / "reports" / "screens" / "2026-10-01-waveB" / "t66-detail.png"
img_edit = ROOT / "reports" / "screens" / "2026-10-01-waveA" / "t65-rename-dialog.png"

def rgb(hexv):
    return RGBColor.from_string(hexv)

def set_bg(slide, color=BG):
    fill = slide.background.fill
    fill.solid()
    fill.fore_color.rgb = rgb(color)

def rect(slide, x, y, w, h, fill, line=None, radius=False, transparency=0):
    shape = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE if radius else MSO_SHAPE.RECTANGLE, Inches(x), Inches(y), Inches(w), Inches(h))
    shape.fill.solid(); shape.fill.fore_color.rgb = rgb(fill); shape.fill.transparency = transparency
    shape.line.color.rgb = rgb(line or fill); shape.line.transparency = 0 if line else 100
    if radius:
        shape.adjustments[0] = 0.12
    return shape

def line(slide, x1, y1, x2, y2, color=LINE, width=1.2, dash=None):
    ln = slide.shapes.add_connector(MSO_CONNECTOR.STRAIGHT, Inches(x1), Inches(y1), Inches(x2), Inches(y2))
    ln.line.color.rgb = rgb(color); ln.line.width = Pt(width)
    if dash:
        ln.line.dash_style = dash
    return ln

def text(slide, txt, x, y, w, h, size=18, color=INK, bold=False, font=FONT, align=PP_ALIGN.LEFT, valign=MSO_ANCHOR.TOP, margin=0.02, italic=False):
    box = slide.shapes.add_textbox(Inches(x), Inches(y), Inches(w), Inches(h))
    tf = box.text_frame; tf.clear(); tf.word_wrap = True; tf.margin_left = Inches(margin); tf.margin_right = Inches(margin); tf.margin_top = Inches(margin); tf.margin_bottom = Inches(margin); tf.vertical_anchor = valign
    p = tf.paragraphs[0]; p.alignment = align
    run = p.add_run(); run.text = txt; run.font.name = font; run.font.size = Pt(size); run.font.bold = bold; run.font.italic = italic; run.font.color.rgb = rgb(color)
    return box

def rich_text(slide, runs, x, y, w, h, size=18, color=INK, align=PP_ALIGN.LEFT, valign=MSO_ANCHOR.TOP, margin=0.02):
    box = slide.shapes.add_textbox(Inches(x), Inches(y), Inches(w), Inches(h))
    tf = box.text_frame; tf.clear(); tf.word_wrap = True; tf.margin_left = Inches(margin); tf.margin_right = Inches(margin); tf.margin_top = Inches(margin); tf.margin_bottom = Inches(margin); tf.vertical_anchor = valign
    p = tf.paragraphs[0]; p.alignment = align
    for item in runs:
        run = p.add_run(); run.text = item[0]; run.font.name = FONT; run.font.size = Pt(item[1] if len(item)>1 else size); run.font.bold = item[2] if len(item)>2 else False; run.font.color.rgb = rgb(item[3] if len(item)>3 else color)
    return box

def title(slide, kicker, head, sub=None, slide_no=None):
    text(slide, kicker.upper(), 0.65, 0.40, 5.5, 0.28, 10, ORANGE, True)
    text(slide, head, 0.65, 0.78, 11.9, 0.65, 28, INK, True)
    if sub:
        text(slide, sub, 0.67, 1.48, 11.3, 0.38, 13, MUTED)
    if slide_no is not None:
        text(slide, f"{slide_no:02d}", 12.12, 0.43, 0.5, 0.25, 10, MUTED, True, align=PP_ALIGN.RIGHT)
    line(slide, 0.65, 1.92, 12.68, 1.92, LINE, 0.8)

def footer(slide, label="TERRA NT · PRT691"):
    line(slide, 0.65, 7.08, 12.68, 7.08, LINE, 0.6)
    text(slide, label, 0.66, 7.15, 4.5, 0.18, 8, MUTED, True)

def add_notes(slide, notes):
    slide.notes_slide.notes_text_frame.text = notes

def add_image_cover(slide, path, x, y, w, h, darken=0):
    # crop image to requested box while preserving aspect ratio
    slide.shapes.add_picture(str(path), Inches(x), Inches(y), width=Inches(w), height=Inches(h))
    if darken:
        rect(slide, x, y, w, h, BG, None, transparency=darken)

def bullet(slide, label, body, x, y, w, accent=ORANGE, label_w=2.05, size=15):
    rect(slide, x, y+0.03, 0.12, 0.12, accent, None, radius=True)
    text(slide, label, x+0.25, y, label_w, 0.28, size, INK, True)
    text(slide, body, x+0.25+label_w, y, w-label_w-0.25, 0.55, size, MUTED)

# 1
s=prs.slides.add_slide(blank); set_bg(s)
add_image_cover(s, img_title, 7.25, 0, 6.08, 7.5, 0)
rect(s, 0, 0, 8.5, 7.5, BG)
text(s, "TERRA NT", 0.72, 0.78, 3.5, 0.35, 15, ORANGE, True)
text(s, "NT self-drive\ntrip planning", 0.68, 1.52, 6.4, 1.45, 36, INK, True)
text(s, "AI-assisted route planning for travellers\nacross the Northern Territory", 0.72, 3.35, 5.75, 0.78, 18, PALE)
text(s, "PRT691 project presentation\nDarwin and External 06", 0.72, 5.98, 4.5, 0.55, 12, MUTED)
text(s, "A research-informed prototype for bringing route evidence, traveller constraints and human review into one workflow.", 7.72, 5.80, 4.65, 0.62, 13, INK, True)
add_notes(s, "Lead: Max Hoang · 0:30\n\nWe are developing Terra NT, a trip-planning prototype for self-drive travel in the Northern Territory. We will show how our research shaped the design, what the current system can do, and what still needs validation.\n\nVisual note: the bundled full_nt.jpg is illustrative artwork, not a documentary photograph of a named place. Confirm usage rights before submission.\nSource: A2 cover and project scope, pp. 1 and 5.")

# 2
s=prs.slides.add_slide(blank); set_bg(s); title(s,"01 · THE PROBLEM","Planning a remote trip means reconciling changing evidence","Terra NT is an advisory planner. The traveller still makes the final decision.",2)
text(s,"A route decision depends on more than a map.",0.72,2.28,5.2,0.45,22,INK,True)
text(s,"Travellers combine information from different owners, with different update cycles and different levels of authority.",0.72,2.82,5.2,0.62,15,MUTED)
categories=[("ROAD",ORANGE),("PARK",TEAL),("PERMIT",RED),("FUEL",BLUE),("WEATHER",ORANGE),("OPERATOR",TEAL)]
for i,(lab,col) in enumerate(categories):
    x=0.75+(i%3)*1.72; y=3.78+(i//3)*0.78
    rect(s,x,y,1.42,0.48,BG,col,True); text(s,lab,x,y+0.13,1.42,0.18,10,col,True,align=PP_ALIGN.CENTER)
line(s,5.88,4.35,7.18,4.35,ORANGE,2)
text(s,"traveller\nconstraints",6.04,3.55,1.05,0.55,13,INK,True,align=PP_ALIGN.CENTER)
rect(s,7.4,2.72,4.96,3.1,"111C2A",LINE,True)
text(s,"REVIEWABLE ITINERARY",7.78,3.08,4.1,0.25,12,ORANGE,True)
text(s,"Route-relevant evidence\n+ vehicle, dates and experience\n+ clear uncertainty",7.78,3.55,4.0,1.18,21,INK,True)
text(s,"AI helps assemble and explain. It does not verify a road, closure or permit in real time.",7.78,5.12,3.9,0.52,13,MUTED)
footer(s)
add_notes(s,"Lead: Ahanaf Alvi · 0:55\n\nOur problem is not a lack of travel information. It is that the information comes from different owners and changes at different rates. The planner should help travellers bring relevant information together while making the source and uncertainty clear.\n\nPrimary user: the self-drive traveller. Other affected stakeholders include visitor-centre staff, small tourism operators, Aboriginal communities and responsible authorities.\n\nSource: A2, pp. 5–6 and 8–9.")

# 3
s=prs.slides.add_slide(blank); set_bg(s); title(s,"02 · RESEARCH","Stakeholder evidence made trust a product requirement","Eight coded response sets show why freshness, source authority and route feasibility lead the design.",3)
text(s,"INTERVIEW THEME PRESENCE",0.82,2.22,4.8,0.22,10,ORANGE,True)
themes=[("Freshness / outdated information",8),("Source transparency and trust",8),("Fragmented planning information",7),("Vehicle and route suitability",7),("Fuel and remote-area safety",7),("Alternative routes / disruption",7),("Permit / access clarity",5),("Human/local knowledge remains relevant",5),("Different user constraints",3),("Local operator accuracy",1)]
chart_x, chart_y, chart_w = 0.82, 2.60, 5.0
for i,(lab,val) in enumerate(themes):
    y=chart_y+i*0.33
    text(s,lab,chart_x,y,2.95,0.20,8.5,PALE,align=PP_ALIGN.RIGHT)
    rect(s,3.92,y+0.03,2.0,0.16,"1B2B3E",None,True)
    rect(s,3.92,y+0.03,2.0*(val/8),0.16,BLUE,None,True)
    text(s,str(val),6.02,y-0.01,0.25,0.2,9,INK,True)
text(s,"Response sets containing the theme (n = 8)",3.22,6.02,3.0,0.18,8.5,MUTED,italic=True)
text(s,"FINDING → DESIGN DECISION",7.00,2.22,5.3,0.22,10,TEAL,True)
rows=[("Multiple sources","One route-specific workflow while keeping source ownership visible."),("Authority + freshness","Show source type and last-checked context as core evidence."),("Vehicle suitability","Capture 2WD, 4WD and towing constraints before route advice.")]
for i,(a,b) in enumerate(rows):
    y=2.66+i*0.94
    rect(s,7.0,y,5.35,0.72,"111C2A",LINE,True); text(s,a,7.25,y+0.13,1.55,0.40,12.5,ORANGE,True); text(s,b,8.93,y+0.13,3.15,0.43,12,PALE)
text(s,"Data context",7.02,5.72,1.0,0.20,10,ORANGE,True)
text(s,"Road, park, permit, fuel, weather and operator records are partial observations of changing conditions, not guarantees of current reality.",8.12,5.68,4.1,0.48,11.5,MUTED)
footer(s,"TERRA NT · A2 FIGURE 1 + TABLE 1")
add_notes(s,"Lead: Shaobin Chen · 1:05\n\nThe report coded eight supplied response sets. Freshness or outdated information and source transparency and trust appeared in all eight. Fragmented planning information, vehicle and route suitability, fuel and remote-area safety, and alternative routes or disruption appeared in seven.\n\nThose findings changed the design priorities: one route-specific workflow, visible source type and last-checked context, and vehicle-aware constraints before route advice.\n\nSource: A2 report Figure 1 and Table 1, p. 6; Table 2, p. 8. The chart is recreated as editable slide content from the report values.")

# 4
s=prs.slides.add_slide(blank); set_bg(s); title(s,"03 · EVOLUTION","The concept narrowed to evidence-grounded advice","Current components are separated from target controls that are still planned.",4)
text(s,"A1",0.8,2.27,0.65,0.25,12,ORANGE,True); text(s,"broad self-drive\ntrip planning",0.8,2.66,1.7,0.55,18,INK,True)
line(s,2.55,3.0,3.18,3.0,ORANGE,1.8)
text(s,"A2",3.35,2.27,0.65,0.25,12,ORANGE,True); text(s,"corridor-specific\ndecision support",3.35,2.66,1.95,0.55,18,INK,True)
line(s,5.34,3.0,5.92,3.0,ORANGE,1.8)
text(s,"NOW",6.08,2.27,0.65,0.25,12,TEAL,True); text(s,"Flutter app +\nfile-based RAG + Gemini",6.08,2.66,2.22,0.55,18,INK,True)
line(s,8.42,3.0,8.98,3.0,ORANGE,1.8)
text(s,"TARGET",9.13,2.27,0.9,0.25,12,BLUE,True); text(s,"retrieve → check →\nexplain a reviewed route",9.13,2.66,2.6,0.55,18,INK,True)
rect(s,0.85,4.24,11.58,1.47,"111C2A",LINE,True)
text(s,"CURRENT IMPLEMENTATION",1.15,4.54,2.0,0.22,10,TEAL,True)
text(s,"Authoritative and advisory sources",1.15,4.95,2.0,0.38,13,PALE,True)
text(s,"→",3.38,4.94,0.35,0.34,20,ORANGE,True,align=PP_ALIGN.CENTER)
text(s,"curated place records",3.88,4.95,1.6,0.38,13,PALE,True)
text(s,"→",5.65,4.94,0.35,0.34,20,ORANGE,True,align=PP_ALIGN.CENTER)
text(s,"Gemini planner service",6.12,4.95,1.72,0.38,13,PALE,True)
text(s,"→",8.0,4.94,0.35,0.34,20,ORANGE,True,align=PP_ALIGN.CENTER)
text(s,"structured itinerary",8.48,4.95,1.52,0.38,13,PALE,True)
text(s,"→",10.16,4.94,0.35,0.34,20,ORANGE,True,align=PP_ALIGN.CENTER)
text(s,"traveller review",10.62,4.95,1.4,0.38,13,PALE,True)
text(s,"WORKSHOP-ALIGNED APPROACH FIT",0.85,5.86,2.8,0.22,10,ORANGE,True)
approaches=[("RAG + rules + constrained wording",4.50,TEAL),("General LLM travel planner",2.76,BLUE),("Train / fine-tune a model",2.12,ORANGE)]
for i,(lab,val,col) in enumerate(approaches):
    x=0.86+i*3.98
    text(s,lab,x,6.15,2.75,0.22,10.5,PALE,True)
    rect(s,x,6.48,2.7,0.16,"1B2B3E",None,True); rect(s,x,6.48,2.7*(val/5),0.16,col,None,True)
    text(s,f"{val:.2f} / 5",x+2.82,6.43,0.7,0.24,12,col,True)
footer(s,"TERRA NT · A2 TABLE 4B + SYSTEM DESIGN")
add_notes(s,"Lead: Max Hoang · 1:05\n\nWe moved from a broad itinerary generator idea toward evidence-grounded decision support. The target architecture separates retrieval, deterministic checks and explanation.\n\nThe report also compared three approaches using a weighted project-fit score. RAG plus deterministic rules and constrained wording scored 4.50 out of 5, ahead of a general LLM travel planner at 2.76 and training or fine-tuning at 2.12. This is decision evidence, not a performance benchmark.\n\nThe current knowledge-base retrieval is file-based and region-filtered. Live road and access feeds and the general deterministic rules layer remain planned.\nEvidence: A2, pp. 10–13, Table 4B, p. 11; current tools/plan_server documentation.")

# 5
s=prs.slides.add_slide(blank); set_bg(s); title(s,"04 · LECTURE → PROJECT","Data lineage and app structure keep the AI system traceable","The lecture themes map to a concrete flow: source evidence enters the system, gets curated and retrieved, then reaches a reviewable mobile workflow.",5)
text(s,"DATA SOURCES",0.82,2.22,2.0,0.22,10,ORANGE,True)
sources=[("NT Road Report","road status / access"),("Parks Australia + NT Parks","park rules / closures"),("NLC permits","authority / access"),("BOM + operators","weather / local context")]
for i,(a,b) in enumerate(sources):
    y=2.60+i*0.58
    rect(s,0.82,y,2.35,0.40,"111C2A",LINE,True); text(s,a,1.00,y+0.08,2.0,0.16,11,PALE,True); text(s,b,3.34,y+0.08,1.82,0.18,10,MUTED)
line(s,5.22,3.70,5.72,3.70,ORANGE,1.8)
rect(s,5.78,2.55,1.75,2.30,"111C2A",TEAL,True); text(s,"CURATE",6.05,2.82,1.2,0.20,10,TEAL,True,align=PP_ALIGN.CENTER); text(s,"place records\nsource authority\nURL + checked date\nregion + tags",6.02,3.26,1.28,1.05,13,INK,True,align=PP_ALIGN.CENTER)
line(s,7.62,3.70,8.10,3.70,ORANGE,1.8)
rect(s,8.16,2.55,1.72,2.30,"111C2A",BLUE,True); text(s,"RETRIEVE",8.42,2.82,1.2,0.20,10,BLUE,True,align=PP_ALIGN.CENTER); text(s,"select records\nby region\ninclude context\nin planner prompt",8.37,3.26,1.28,1.05,13,INK,True,align=PP_ALIGN.CENTER)
line(s,9.98,3.70,10.46,3.70,ORANGE,1.8)
rect(s,10.52,2.55,1.90,2.30,"111C2A",ORANGE,True); text(s,"EXPLAIN",10.84,2.82,1.25,0.20,10,ORANGE,True,align=PP_ALIGN.CENTER); text(s,"Gemini structured\noutput → Flutter\nscreens → human\nreview",10.77,3.26,1.38,1.05,13,INK,True,align=PP_ALIGN.CENTER)
text(s,"WHAT THE DATA DOES NOT DO",0.82,5.25,2.5,0.22,10,RED,True)
text(s,"The current records are curated context, not live road, closure, weather, fuel, permit or booking status. A checked date shows when a person reviewed the source, not a guarantee that conditions remain current.",0.82,5.58,5.8,0.66,12,MUTED)
text(s,"LECTURE COVERAGE",7.00,5.25,2.0,0.22,10,TEAL,True)
coverage=[("W01 + W06","Stakeholders → requirements"),("W02 + W03","Data context + human-centred design"),("W04 + W05 + W09 + W12","Responsible AI, readiness, privacy and traceability"),("W07 + W08 + W10 + W11","Evaluation, iteration, refinement and presentation")]
for i,(a,b) in enumerate(coverage):
    y=5.58+i*0.31
    text(s,a,7.0,y,2.0,0.17,9.5,ORANGE,True); text(s,b,9.05,y,3.25,0.17,9.5,PALE)
footer(s,"TERRA NT · DATA LINEAGE + COURSE COVERAGE")
add_notes(s,"Lead: Max Hoang · 0:55\n\nThis slide makes the data and app structure explicit. Our source categories include NT Road Report, Parks Australia and NT Parks, Northern Land Council permit information, BOM forecasts and operator context. We curate place records with source authority, URLs, checked dates, region and tags.\n\nThe current planner retrieves file-based records by region and includes them in the Gemini prompt. Gemini returns structured itinerary output, which the Flutter app presents for traveller review. The current data is not a live feed, so checked dates are evidence metadata rather than a promise of current conditions.\n\nThe project also applies the lecture sequence: stakeholders and discovery become requirements; data context and human-centred design shape the workflow; responsible AI, readiness, privacy and lifecycle traceability constrain the system; testing, iteration, refinement and presentation provide the evidence loop.\nEvidence: A2 pp. 5–13, 14–17, 41–45; current tools/plan_server/README.md and rag/README.md.")

# 6
s=prs.slides.add_slide(blank); set_bg(s); title(s,"05 · DATA SOURCES","Terra NT combines evidence owned by different organisations","Each source contributes a different kind of route context. The planner keeps the source name and checked date with the record.",6)
text(s,"SOURCE",0.82,2.25,2.25,0.22,10,ORANGE,True); text(s,"WHAT IT CONTRIBUTES",3.28,2.25,2.45,0.22,10,TEAL,True); text(s,"HOW WE TREAT IT",6.04,2.25,5.95,0.22,10,BLUE,True)
source_rows=[
    ("NT Road Report", "Road and access context", "Advisory evidence. Confirm current closures and conditions with the official source."),
    ("Parks Australia + NT Parks", "Park rules, closures and visitor context", "Authority context. Do not infer that a site is open or accessible today."),
    ("Northern Land Council", "Permit and access authority context", "Permission boundary. The app must not invent cultural access approval."),
    ("BOM + local operators", "Weather and local travel context", "Supporting context. Keep the source and review date visible."),
]
for i,(a,b,c) in enumerate(source_rows):
    y=2.62+i*0.76
    line(s,0.82,y+0.57,12.48,y+0.57,LINE,0.6)
    text(s,a,0.82,y,2.25,0.37,14,INK,True); text(s,b,3.28,y,2.45,0.38,12.5,PALE); text(s,c,6.04,y,6.0,0.44,11.5,MUTED)
rect(s,0.82,5.92,11.66,0.62,"111C2A",TEAL,True)
text(s,"Every place record keeps",1.08,6.10,1.75,0.18,10,TEAL,True); text(s,"authority · URL · checked date · region · tags · evidence text",3.00,6.10,5.35,0.18,12,INK,True); text(s,"This makes the origin of an answer inspectable.",8.62,6.10,3.45,0.18,11,MUTED)
footer(s,"TERRA NT · SOURCE AUTHORITY + FRESHNESS")
add_notes(s,"Lead: Max Hoang · 0:35\n\nBefore explaining RAG, name the data. NT Road Report contributes road and access context. Parks Australia and NT Parks contribute park rules and closure context. Northern Land Council information contributes permit and authority context. BOM and local operators add weather and local context.\n\nEach record keeps an authority, URL, checked date, region and tags. That metadata lets the team inspect where a recommendation came from. It does not make the record live. The audience should hear this distinction before we explain the AI layer.\nEvidence: A2 pp. 8–13; current tools/plan_server/rag/README.md and places.py.")

# 7
s=prs.slides.add_slide(blank); set_bg(s); title(s,"06 · DATA PROCESSING","Source material becomes route-ready evidence through a controlled preparation step","The system does not send an unstructured web search directly to the model.",7)
stages=[("1","COLLECT","official pages\noperator context"),("2","NORMALISE","place name\nregion + tags"),("3","CURATE","source + URL\nchecked date"),("4","FILTER","match route\nregion + request"),("5","PASS CONTEXT","records enter\nplanner prompt")]
for i,(n,head,body) in enumerate(stages):
    x=0.82+i*2.42
    rect(s,x,2.62,1.95,1.72,"111C2A",LINE if i not in (2,4) else (TEAL if i==2 else BLUE),True)
    text(s,n,x+0.14,2.80,0.30,0.25,18,ORANGE,True); text(s,head,x+0.52,2.82,1.20,0.20,10,TEAL if i==2 else BLUE,True); text(s,body,x+0.16,3.30,1.60,0.55,14,INK,True,align=PP_ALIGN.CENTER)
    if i<4: text(s,"→",x+2.03,3.24,0.32,0.28,20,ORANGE,True,align=PP_ALIGN.CENTER)
text(s,"EXAMPLE RECORD",0.82,4.92,1.7,0.22,10,ORANGE,True)
rect(s,0.82,5.26,5.72,1.10,"111C2A",LINE,True)
text(s,"Jabiru",1.08,5.52,1.05,0.23,17,INK,True); text(s,"region: Top End  ·  tag: culture / nature  ·  authority: park source",2.25,5.47,3.85,0.26,11,PALE); text(s,"source URL + checked date travel with the text",2.25,5.83,3.85,0.20,10,MUTED)
text(s,"WHY THIS STEP MATTERS",7.02,4.92,2.4,0.22,10,TEAL,True)
text(s,"Preparation reduces irrelevant context and preserves traceability. It also gives the team a place to detect missing, duplicated or stale records before generation.",7.02,5.28,5.30,0.70,16,PALE,True)
footer(s,"TERRA NT · DATA PREPARATION")
add_notes(s,"Lead: Shaobin Chen · 0:35\n\nThis is the preparation layer. We collect source material, normalise the place name and region, curate authority and checked-date metadata, filter records for the requested corridor and pass only the relevant context into the planner prompt.\n\nThe example is a place record for Jabiru. The record carries the evidence text and its source metadata together. This step matters because it gives us a human-review point before the model generates anything.\nEvidence: current tools/plan_server/rag/README.md and places.py; A2 pp. 10–13.")

# 8
s=prs.slides.add_slide(blank); set_bg(s); title(s,"07 · RAG","RAG grounds the response in relevant records before Gemini writes the itinerary","Retrieval supplies context. It does not prove that a road, permit or closure is current.",8)
rag=[("TRAVELLER REQUEST","dates, vehicle,\ninterests, corridor",ORANGE),("REGION FILTER","select matching\nplace records",TEAL),("RETRIEVED CONTEXT","source-linked\nrecords + caveats",BLUE),("STRUCTURED PROMPT","constraints +\ncontext + schema",ORANGE),("ITINERARY JSON","stops, reasons,\nchecks and notes",TEAL)]
for i,(head,body,col) in enumerate(rag):
    x=0.82+i*2.42
    rect(s,x,2.66,1.94,1.60,"111C2A",col,True); text(s,head,x+0.12,2.93,1.70,0.25,9.5,col,True,align=PP_ALIGN.CENTER); text(s,body,x+0.16,3.38,1.60,0.52,14,INK,True,align=PP_ALIGN.CENTER)
    if i<4: text(s,"→",x+2.02,3.22,0.32,0.28,20,ORANGE,True,align=PP_ALIGN.CENTER)
rect(s,0.82,4.88,3.72,1.24,"111C2A",TEAL,True); text(s,"RAG DOES",1.04,5.12,1.0,0.18,10,TEAL,True); text(s,"Finds relevant records and carries their context into the prompt.",1.04,5.47,3.1,0.40,13,PALE,True)
rect(s,4.80,4.88,3.72,1.24,"111C2A",RED,True); text(s,"RAG DOES NOT",5.02,5.12,1.35,0.18,10,RED,True); text(s,"Guarantee current conditions or replace official checks.",5.02,5.47,3.1,0.40,13,PALE,True)
rect(s,8.78,4.88,3.70,1.24,"111C2A",BLUE,True); text(s,"HUMAN CONTROL",9.00,5.12,1.45,0.18,10,BLUE,True); text(s,"The traveller reviews, edits and accepts the proposed route.",9.00,5.47,3.1,0.40,13,PALE,True)
footer(s,"TERRA NT · FILE-BASED, REGION-FILTERED RAG")
add_notes(s,"Lead: Max Hoang · 0:40\n\nRAG means retrieval-augmented generation. The traveller request includes dates, vehicle, interests and corridor. The current service filters the file-based place records by region, brings relevant source-linked records into the prompt, and asks Gemini for structured itinerary output.\n\nThe important boundary is that RAG improves relevance and traceability. It does not turn a checked record into a live road or permit feed. The human still reviews and edits the route. This is file-based, region-filtered retrieval, not a vector database and not an autonomous safety system.\nEvidence: current tools/plan_server/rag/README.md, places.py and server.py; A2 Table 4B, p. 11.")

# 9
s=prs.slides.add_slide(blank); set_bg(s); title(s,"08 · APP STRUCTURE","The app turns a structured plan into a reviewable traveller workflow","The app is the interface between the planner service and the person making the trip decision.",9)
app=[("TRAVELLER","enter route\nconstraints",ORANGE),("FLUTTER APP","form, map,\nstops, edits",TEAL),("PLANNER API","Firebase auth\n+ request",BLUE),("RAG + GEMINI","retrieve context\n+ return JSON",ORANGE),("FLUTTER RESULT","itinerary, map\n+ stop detail",TEAL)]
for i,(head,body,col) in enumerate(app):
    x=0.82+i*2.42
    rect(s,x,2.55,1.94,1.72,"111C2A",col,True); text(s,head,x+0.12,2.86,1.70,0.22,10,col,True,align=PP_ALIGN.CENTER); text(s,body,x+0.16,3.34,1.60,0.52,14,INK,True,align=PP_ALIGN.CENTER)
    if i<4: text(s,"→",x+2.02,3.20,0.32,0.28,20,ORANGE,True,align=PP_ALIGN.CENTER)
line(s,11.50,4.48,1.78,4.48,BLUE,1.5)
text(s,"review and edit",5.48,4.30,2.0,0.22,12,BLUE,True,align=PP_ALIGN.CENTER)
text(s,"The loop returns to the traveller. The user can inspect a stop, change the route, or reject the suggestion.",2.20,5.02,8.90,0.42,21,INK,True,align=PP_ALIGN.CENTER)
rect(s,2.72,5.82,7.94,0.52,"2A1D1D",RED,True); text(s,"CURRENT LIMIT: the complete authenticated app-to-planner flow still needs verification on a connected device.",2.94,5.98,7.48,0.18,10,RED,True,align=PP_ALIGN.CENTER)
footer(s,"TERRA NT · FLUTTER + PLANNER SERVICE")
add_notes(s,"Lead: Tarik Bulut · 0:40\n\nThe app structure has five steps. The traveller enters a route and constraints in Flutter. The app sends an authenticated request to the planner API. The planner retrieves source context and asks Gemini for structured JSON. Flutter renders the itinerary, map and stop details. The user then reviews and edits the proposed route.\n\nThis is a review loop, not a one-way answer. The current limitation is that we still need to verify the complete authenticated app-to-planner flow on a connected device.\nEvidence: current Flutter app, tools/plan_server/server.py and presentation tracker.")

# 10
s=prs.slides.add_slide(blank); set_bg(s); title(s,"09 · CURRENT BUILD","The current app makes a route inspectable and editable","Implementation evidence comes from the Flutter mobile experience and the planner service, with clear limits.",10)
rect(s,0.72,2.3,3.24,3.93,"111C2A",LINE,True); add_image_cover(s,img_saved,0.90,2.48,2.88,3.10,0); text(s,"Current simulator output",0.98,5.72,2.5,0.22,13,INK,True); text(s,"Debug build · offline suggestion",0.98,6.02,2.55,0.2,10,MUTED)
rect(s,4.25,2.3,3.24,3.93,"111C2A",LINE,True); add_image_cover(s,img_detail,4.43,2.48,2.88,3.10,0); text(s,"Stop detail",4.51,5.72,2.5,0.22,13,INK,True); text(s,"Current capture · route content",4.51,6.02,2.55,0.2,10,MUTED)
text(s,"WHAT EXISTS",8.02,2.36,4.0,0.24,11,ORANGE,True)
bullet(s,"Flutter app","Onboarding, interactive map, itinerary and stop views, with route controls.",8.02,2.78,4.55,ORANGE,1.32,13)
bullet(s,"Planner","Gemini structured-output backend with 12 source-linked place records.",8.02,3.68,4.55,TEAL,1.32,13)
bullet(s,"Map","OpenFreeMap basemap and best-effort OSRM geometry. Straight connectors remain the fallback.",8.02,4.58,4.55,BLUE,1.32,13)
rect(s,8.02,5.72,4.55,0.58,"2A1D1D",RED,True); text(s,"CURRENT SIMULATOR CAPTURE · DEBUG BUILD · APP-TO-PLANNER FLOW STILL NEEDS VERIFICATION",8.26,5.88,4.05,0.25,9.2,RED,True)
footer(s)
add_notes(s,"Lead: Tarik Bulut · 0:50\n\nThe mobile experience and the planner service are progressing as separate parts of the system. The current simulator capture shows a debug build with an offline suggestion from stored places. It is useful app evidence, but it is not proof of a live Gemini-generated route.\n\nThe service has returned structured Gemini output and uses curated place records, but the complete authenticated app-to-planner flow still needs verification on a connected device.\n\nEthical impact: the app keeps the traveller responsible for the final decision and avoids presenting stale context as current safety information. Scalability depends on adding governed, region-tagged records corridor by corridor and validating the rules and source quality before expansion.\nEvidence: A2, pp. 10–13; current presentation tracker and planner documentation.")

# 7
s=prs.slides.add_slide(blank); set_bg(s); title(s,"10 · RESPONSIBLE AI","The largest risk is a fluent answer built on stale evidence","Controls are shown with their current status so planned safeguards are not mistaken for completed ones.",11)
headers=[("RISK",0.82,3.45),("CURRENT RESPONSE / REMAINING CONTROL",4.55,7.86),("STATUS",11.55,1.0)]
for h,x,w in headers: text(s,h,x,2.28,w,0.22,10,ORANGE,True)
risks=[("Stale or incomplete road/access information","Point users to official live checks; no live road or closure feed yet.","PARTIAL",ORANGE),("Incorrect permit or cultural-access claim","Do not infer permission. Rely on responsible authorities and show uncertainty.","IN PLACE",TEAL),("Fluent but unsafe recommendation","Deterministic hard checks remain a target requirement.","PLANNED",BLUE),("Privacy and account security","Keep planner authentication enabled; use de-identified research records.","IN PLACE",TEAL)]
for i,(r,c,st,col) in enumerate(risks):
    y=2.73+i*0.78
    line(s,0.82,y+0.66,12.5,y+0.66,LINE,0.6)
    text(s,r,0.82,y,3.35,0.48,13,INK,True)
    text(s,c,4.55,y,6.5,0.48,12,PALE)
    rect(s,11.55,y+0.02,1.0,0.30,"111C2A",col,True); text(s,st,11.55,y+0.10,1.0,0.12,8,col,True,align=PP_ALIGN.CENTER)
rect(s,0.82,6.00,3.72,0.66,"111C2A",RED,True); text(s,"ETHICS",1.00,6.12,0.85,0.16,9.5,RED,True); text(s,"Authority, permits and cultural access stay visible.",1.92,6.11,2.35,0.30,9.5,PALE)
rect(s,4.78,6.00,3.72,0.66,"111C2A",TEAL,True); text(s,"IMPACT",4.96,6.12,0.80,0.16,9.5,TEAL,True); text(s,"More transparent planning and fewer repeated checks.",5.82,6.11,2.45,0.30,9.5,PALE)
rect(s,8.74,6.00,3.98,0.66,"111C2A",BLUE,True); text(s,"SCALABILITY",8.92,6.12,1.05,0.16,9.5,BLUE,True); text(s,"Expand corridor by corridor after validation.",10.02,6.11,2.42,0.30,9.5,PALE)
footer(s)
add_notes(s,"Lead: Shaobin Chen · 0:55\n\nOur highest-impact risk is a confident recommendation based on stale or incomplete information. The knowledge base preserves source context, but this does not make the data current. A general rules engine is still outstanding, so Terra NT remains an advisory prototype and travellers must confirm live road, park and permit conditions.\n\nEthically, authority, permit and cultural-access boundaries must stay visible. The intended impact is more transparent planning and less repeated checking, but we should not claim safety improvement until the rules and user evaluation are complete. For scalability, a region-tagged data model can extend corridor by corridor, provided each new source set is governed, refreshed and tested.\n\nEvidence: A2, pp. 14–15, Table 5 and Appendix D; current RAG dataset guidance.")

# 8
s=prs.slides.add_slide(blank); set_bg(s); title(s,"11 · EVALUATION","The strongest result is narrow, and that is useful","9/9 functional checks passed for the browser prototype and curated snapshot on 11 September 2026.",12)
rect(s,0.82,2.42,3.2,2.8,"111C2A",LINE,True); text(s,"9 / 9",1.08,2.92,2.65,0.75,42,TEAL,True,align=PP_ALIGN.CENTER); text(s,"predefined functional checks passed",1.18,3.84,2.45,0.55,15,INK,True,align=PP_ALIGN.CENTER); text(s,"Chromium · 390 × 844 viewport",1.18,4.62,2.45,0.2,10,MUTED,align=PP_ALIGN.CENTER)
breakdown=[("4/4","personalisation\n+ scheduling",ORANGE),("2/2","safety / evidence\nsnapshot",TEAL),("3/3","human control\n+ interaction",BLUE)]
for i,(n,lab,col) in enumerate(breakdown):
    x=4.55+i*2.55
    text(s,n,x,2.64,2.15,0.5,28,col,True,align=PP_ALIGN.CENTER)
    text(s,lab,x,3.26,2.15,0.55,13,INK,True,align=PP_ALIGN.CENTER)
    rect(s,x+0.4,4.18,1.35,0.13,col,None,True)
text(s,"WHAT THIS RESULT MEANS",4.52,5.0,3.0,0.22,10,ORANGE,True)
text(s,"Preliminary functional evidence for the browser prototype and curated snapshot.",4.52,5.32,3.4,0.52,14,PALE)
text(s,"WHAT IT DOES NOT MEAN",8.12,5.0,3.2,0.22,10,RED,True)
text(s,"It does not validate the Flutter app, Gemini/RAG retrieval accuracy, current NT conditions, field safety or real-user trust.",8.12,5.32,3.95,0.72,14,PALE)
footer(s,"TERRA NT · BROWSER PROTOTYPE EVIDENCE")
add_notes(s,"Lead: Ahanaf Alvi · 0:55\n\nWe completed nine functional checks on the browser prototype. That result covers its curated demonstration behaviours only. It is not a test of the Flutter app or the newer Gemini/RAG service. Our next evaluation needs to test retrieval support, constraint handling and whether users can understand the evidence.\n\nState the boundary clearly: “9/9” is not “100% accurate” and is not a safety benchmark.\nEvidence: A2, pp. 16–17, especially Table 7 and Appendix E6.")

# 9
s=prs.slides.add_slide(blank); set_bg(s); title(s,"12 · LIVE DEMO","The traveller reviews a route, then keeps control","Demo target: 2:35 · Start signed in · Say whether the result is live Gemini, fixture or seeded content.",13)
steps=[("01","Open or generate","Use the Darwin–Kakadu–Katherine / Top End corridor."),("02","Inspect the route","Show stop order and route geometry. Explain the fallback."),("03","Edit the plan","Open a stop, then reorder or remove/restore it."),("04","Close responsibly","Remind the audience to check official live conditions.")]
for i,(n,head,body) in enumerate(steps):
    y=2.35+i*0.83
    rect(s,0.82,y,0.48,0.48,BLUE,None,True); text(s,n,0.82,y+0.13,0.48,0.18,10,INK,True,align=PP_ALIGN.CENTER)
    text(s,head,1.55,y+0.03,2.2,0.22,15,INK,True); text(s,body,3.8,y+0.03,4.35,0.35,13,MUTED)
rect(s,8.55,2.34,3.85,3.32,"111C2A",LINE,True)
add_image_cover(s,img_detail,8.77,2.55,3.42,2.2,0)
text(s,"Use the current stop-detail capture as visual support if the network or login blocks the live path.",8.78,4.94,3.35,0.48,12,PALE)
rect(s,0.82,6.03,11.6,0.56,"2A1D1D",RED,True); text(s,"Fallback: show the prepared local itinerary and name the unavailable step. Never call cached or seeded output a live AI generation.",1.1,6.19,11.05,0.2,11,INK,True,align=PP_ALIGN.CENTER)
footer(s,"TERRA NT · DEMO SCRIPT BUILT INTO NOTES")
add_notes(s,"Lead: Max Hoang, with brief hand-offs · 2:35\n\nDemo objective: show how a traveller creates or opens an itinerary, understands the route and retains control.\n\nSequence:\n1. Start already signed in.\n2. Choose the Darwin–Kakadu–Katherine / Top End corridor so the demo matches the A2 research scope.\n3. Generate or open the prepared itinerary and say whether it came from live Gemini, a fixture or a seeded route.\n4. Show the route and stop order. Explain that OSRM geometry is visual route guidance and can fall back to straight connectors.\n5. Open one stop, then reorder or remove/restore a stop.\n6. Close with: “The map supports orientation, but current road and access conditions still need confirmation from official sources.”\n\nFallback: use the prepared local itinerary or the capture shown on the slide. Do not claim a live AI generation if the demo uses cached, fixture or seeded output.\nEvidence: compulsory live demonstration within 10 minutes; current tracker and A2 pp. 10–13, 16–17.")

# 10
s=prs.slides.add_slide(blank); set_bg(s); title(s,"13 · NEXT MILESTONE","Traceable recommendations are the next milestone","The workflow is together. The evidence model and live validation still need to catch up.",14)
add_image_cover(s,img_title,7.65,2.12,5.0,4.35,0)
rect(s,0.72,2.25,6.25,3.8,"111C2A",LINE,True)
nexts=[("01","Verify the authenticated app-to-Gemini flow on a connected iPhone."),("02","Retain source authority and freshness with each itinerary fact."),("03","Add and evaluate deterministic checks for closures, access, permits and vehicle suitability."),("04","Integrate live official data, then test stale and missing records with travellers and staff.")]
for i,(n,body) in enumerate(nexts):
    y=2.58+i*0.75
    text(s,n,1.03,y,0.42,0.2,12,ORANGE,True); text(s,body,1.65,y,4.78,0.42,14,PALE,True)
text(s,"Terra NT brings the planning workflow together. The next milestone is proving that route recommendations remain traceable and useful when the underlying conditions change.",0.98,5.62,5.55,0.54,13,INK,True)
footer(s,"TERRA NT · QUESTIONS")
add_notes(s,"Lead: Tarik Bulut · 0:55\n\nOur next work is to verify the authenticated app-to-Gemini flow on a connected iPhone, expand the evidence model so generated facts retain source authority and freshness, add deterministic checks for closures, access, permits and vehicle suitability, and evaluate the experience with travellers and relevant staff.\n\nClosing line: “Terra NT brings the planning workflow together. The next milestone is proving that route recommendations remain traceable and useful when the underlying conditions change.”\nEvidence: A2, pp. 5, 8–9, 14–17; current presentation tracker and RAG documentation.")

out = OUT_DIR / "Terra-NT-Team-Presentation.pptx"
prs.save(out)
print(out)
