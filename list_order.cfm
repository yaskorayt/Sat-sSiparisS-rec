<cfquery name="get_process_type" datasource="#DSN#">
	SELECT
		PTR.STAGE,
		PTR.PROCESS_ROW_ID,
		PT.PROCESS_NAME,
		PT.PROCESS_ID
	FROM
		PROCESS_TYPE_ROWS PTR,
		PROCESS_TYPE_OUR_COMPANY PTO,
		PROCESS_TYPE PT
	WHERE
		PT.IS_ACTIVE = 1 AND
		PT.PROCESS_ID = PTR.PROCESS_ID AND
		PT.PROCESS_ID = PTO.PROCESS_ID AND
		PTO.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND
		<cfif listlen(attributes.fuseaction,'.') eq 2 and listgetat(attributes.fuseaction,2,'.') is 'list_order_instalment'>
			PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#listfirst(attributes.fuseaction,'.')#.list_order_instalment%">
		<cfelse>
			PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#listfirst(attributes.fuseaction,'.')#.list_order%">
			AND PT.FACTION NOT LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#listfirst(attributes.fuseaction,'.')#.list_order_instalment%">
		</cfif>
	ORDER BY
		PT.PROCESS_NAME,
		PTR.LINE_NUMBER
</cfquery>
<cfif isdefined("attributes.is_instalment")>
	<cfset head = getlang(796,'Taksitli Satışlar',58208)>
<cfelse>
	<cfset head = getlang(6,'Satış Siparişleri',58207)>
</cfif>

<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	
	<cf_box>
		<cfform name="order_form" action="#request.self#?fuseaction=#url.fuseaction#">
			<cf_box_search>
				<cfif isdefined("attributes.is_instalment") and attributes.is_instalment eq 1>
					<input name="is_instalment" id="is_instalment" value="1" type="hidden">
				</cfif>
				<input name="form_varmi" id="form_varmi" value="1" type="hidden">
				<cfoutput>
				<div class="form-group">
					<div class="input-group">
						<cfsavecontent variable="message"><cf_get_lang dictionary_id='57477.hatalı veri'>:<cf_get_lang dictionary_id='57742.Tarih'>!</cfsavecontent>
						<input type="text" name="start_date"  value="#dateformat(attributes.start_date,dateformat_style)#" validate="#validate_style#" maxlength="10" message="#message#">
						<span class="input-group-addon"><cf_wrk_date_image date_field="start_date"></span>
					</div>
					<div class="input-group">
						<cfsavecontent variable="message"><cf_get_lang dictionary_id='57477.hatalı veri'>:<cf_get_lang dictionary_id='57742.Tarih'>!</cfsavecontent>
						<input type="text" name="finish_date" value="#dateformat(attributes.finish_date,dateformat_style)#" validate="#validate_style#" maxlength="10" message="#message#">
						<span class="input-group-addon"><cf_wrk_date_image date_field="finish_date"></span>
					</div>
				</div>  
				<div class="form-group">
					<cf_wrk_search_button button_type="4" search_function='input_control()'>
					<cf_workcube_file_action pdf='1' mail='1' doc='1' print='1'>
				</div>
				<div class="form-group">
					<a class="ui-btn ui-btn-gray2" href="javascript://" id="sepet_in_sepet" name="sepet_in_sepet" onclick="openmodal()"><i class="fa fa-shopping-basket"></i></a>
				</div> 
				</cfoutput>    
			</cf_box_search>
			<cf_box_search_detail>
					<div class="col col-3 col-md-8 col-sm-12" type="column" sort="true" index="1">						
						<div class="form-group" id="item-company_id">
							<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id='57519.Cari Hesap'></label>							
							<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
								<div class="input-group">
									<input type="hidden" name="consumer_id" id="consumer_id" value="<cfif isdefined("attributes.consumer_id")><cfoutput>#attributes.consumer_id#</cfoutput></cfif>">
									<input type="hidden" name="company_id" id="company_id" value="<cfif isdefined("attributes.company_id")><cfoutput>#attributes.company_id#</cfoutput></cfif>">
									<input type="hidden" name="member_type" id="member_type" value="<cfif isdefined("attributes.member_type")><cfoutput>#attributes.member_type#</cfoutput></cfif>">
									<input name="member_name" type="text" id="member_name" placeholder="<cfoutput>#getLang('main',107)#</cfoutput>" onfocus="AutoComplete_Create('member_name','MEMBER_NAME,MEMBER_PARTNER_NAME,MEMBER_CODE','MEMBER_NAME,MEMBER_PARTNER_NAME,MEMBER_CODE','get_member_autocomplete','\'1,2\'','CONSUMER_ID,COMPANY_ID,MEMBER_TYPE','consumer_id,company_id,member_type','','3','250');" value="<cfif isdefined("attributes.member_name") and len(attributes.member_name)><cfoutput>#attributes.member_name#</cfoutput></cfif>" autocomplete="off">
									<cfset str_linke_ait="&field_consumer=order_form.consumer_id&field_comp_id=order_form.company_id&field_member_name=order_form.member_name&field_type=order_form.member_type">
									<span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_all_pars<cfoutput>#str_linke_ait#<cfif session.ep.isBranchAuthorization>&is_store_module=1</cfif></cfoutput>&select_list=7,8&keyword='+encodeURIComponent(document.order_form.member_name.value));"></span>
								</div>
							</div>
						</div>
						<div class="form-group" id="item-prod_cat">						
							<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id='29401.Ürün Kategorileri'></label>
							<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
								<cfinclude template="../query/get_product_cats.cfm">
								<select name="prod_cat" id="prod_cat">
									<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
									<cfoutput query="GET_PRODUCT_CATS">
										<cfif listlen(hierarchy,".") lte 3>
											<option value="#hierarchy#"<cfif (attributes.prod_cat eq hierarchy) and len(attributes.prod_cat) eq len(hierarchy)> selected</cfif>>#hierarchy#-#product_cat#</option>
										</cfif>
									</cfoutput>
								</select>                       
							</div>
						</div>
						<div class="form-group" id="item-product_id">
							<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id='57657.Ürün'></label>						
							<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
								<div class="input-group">
									<input type="hidden" name="product_id" id="product_id" <cfif len(attributes.product_id) and len(attributes.product_name)>value="<cfoutput>#attributes.product_id#</cfoutput>"</cfif>>
									<input name="product_name" type="text" id="product_name" placeholder="<cfoutput><cf_get_lang dictionary_id='57657.Ürün'></cfoutput>" onfocus="AutoComplete_Create('product_name','PRODUCT_NAME','PRODUCT_NAME','get_product','0','PRODUCT_ID','product_id','','3','100');" value="<cfif len(attributes.product_id) and len(attributes.product_name)><cfoutput>#attributes.product_name#</cfoutput></cfif>" autocomplete="off">
									<span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&product_id=order_form.product_id&field_name=order_form.product_name&keyword='+encodeURIComponent(document.order_form.product_name.value));"></span>
								</div>
							</div>
						</div>						
					</div>	
			</cf_box_search_detail>
		</cfform>
	</cf_box>
	
	<cf_box title="#head#" uidrop="1" hide_table_column="1" woc_setting = "#{ checkbox_name : 'print_order_id'}#">
		<form name="send_print_page">
		<div id="sales_list">
			<cf_grid_list>
				<thead>
					<tr>
						<th><cf_get_lang dictionary_id='58577.Sira'></th>
						<cfif (isdefined('attributes.listing_type') and attributes.listing_type eq 2)><!--- Eger satir bazinda listeleme yapiliyorsa --->
						
							<th width="1%" class="el_hidden"></th>
						
						</cfif>
						<th><cf_get_lang dictionary_id='57487.no'></th>
						<th><cf_get_lang dictionary_id='57742.tarih'></th>
						<th><cf_get_lang dictionary_id='40953.teslim'></th>
						<cfif (isdefined('attributes.listing_type') and attributes.listing_type eq 2)><!--- Eger satir bazinda listeleme yapiliyorsa --->
							<th><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
							<th><cf_get_lang dictionary_id='57657.rn'></th>
							<cfif x_show_spec_info>
								<th><cf_get_lang dictionary_id='57647.Spec'></th>
			
							</cfif>
						</cfif>
						<th><cf_get_lang dictionary_id='38554.sirket yetkili'></th>
						<cfif (isdefined('attributes.listing_type') and attributes.listing_type eq 2)><!--- Eger satir bazinda listeleme yapiliyorsa --->
							<th><cf_get_lang dictionary_id='57635.Miktar'></th>
							<th><cf_get_lang dictionary_id='58506.Iptal'></th>
							<th><cf_get_lang dictionary_id='57636.Birim'></th>
						</cfif>
							<th><cf_get_lang dictionary_id='30024.KDVsiz'><cf_get_lang dictionary_id='57673.tutar'></th>
						<th><cf_get_lang dictionary_id='57673.tutar'></th>
						<th><cf_get_lang dictionary_id='58864.Para Br'></th>
						<th><cf_get_lang dictionary_id='30024.KDVsiz'><cf_get_lang dictionary_id ='58056.Dvizli Tutar'></th>
						<th><cf_get_lang dictionary_id ='58056.Dvizli Tutar'></th>
						<th><cf_get_lang dictionary_id='58864.Para Br'></th>
						<!-- sil -->
						<cfif isdefined("attributes.is_instalment")>
							<th width="20" class="header_icn_none text-center"><a href="<cfoutput>#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.</cfoutput>list_order_instalment&event=add"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></th>
						<cfelse>
							<th width="20" class="header_icn_none text-center"><a href="<cfoutput>#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.</cfoutput>list_order&event=add"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></th>
						</cfif>
						<!--- <th width="20" class="text-center"><i class="fa fa-print" title="<cf_get_lang dictionary_id='57474.Yazdir'>"></i></th> --->
							<!--- Boxa woc'a gönder eklendiği için yoruma alındı. F.Z.DERE--->
							<!--- <cfif x_select_row_print eq 1 and attributes.listing_type eq 1 and get_order_list.recordcount>
								<th width="20" align="center" class="header_icn_none text-center" nowrap="nowrap">
									<cfoutput><a href="javascript://" onclick="send_print_();"><i class="fa fa-print" title="<cf_get_lang dictionary_id='58057.Toplu'><cf_get_lang dictionary_id='57474.Yazdir'>"></i></a></cfoutput></br>
									<input type="checkbox" name="allSelectDemand" id="allSelectDemand" onclick="wrk_select_all('allSelectDemand','print_islem_id');">
								</th>
							</cfif>  --->
							<cfif  get_order_list.recordcount>
								<th width="20" class="text-center header_icn_none">
									<cfif  get_order_list.recordcount eq 1><a href="javascript://" onclick="send_print_reset();"><i class="fa fa-print" alt="<cf_get_lang dictionary_id='57389.Print Sayisi Sifirla'>" title="<cf_get_lang dictionary_id='57389.Print Sayisi Sifirla'>"></i></a></cfif>
									<input type="checkbox" name="allSelectDemand" id="allSelectDemand" onclick="wrk_select_all('allSelectDemand','print_order_id');">
								</th>
							</cfif> 
						<!-- sil -->
					</tr>
				</thead>
